/// Contact List Screen
/// Displays, filters, and manages contacts. Includes manual dark mode toggle.
/// Date: 2025-11-17
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/contact.dart';
import '../db/database_helper.dart';
import 'contact_form_screen.dart';

/// Main screen for viewing and managing contacts.
class ContactListScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeModeChanged;
  const ContactListScreen({Key? key, this.onThemeModeChanged})
      : super(key: key);

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  // Removed unused _currentThemeMode field
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Contact> contacts = [];
  String searchQuery = '';
  String selectedGroup = 'Tous';

  String _sortMode = 'name_asc'; // name_asc | name_desc | favorite_first
  int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final list = await _dbHelper.getContacts();
      setState(() => contacts = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur en chargeant les contacts')));
    }
  }

  String contactsToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('name,phone,group,isFavorite');
    for (var c in contacts) {
      buffer.writeln('"${c.name}","${c.phone}","${c.group}",${c.isFavorite}');
    }
    return buffer.toString();
  }

  Future<void> importContactsFromCsv(String csv) async {
    final lines = csv.split('\n');
    if (lines.length < 2) return;
    final imported = <Contact>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = RegExp(r'"(.*?)"|([^,]+)')
          .allMatches(line)
          .map((m) => m.group(1) ?? m.group(2))
          .toList();
      if (parts.length >= 4) {
        imported.add(Contact(
          name: parts[0] ?? '',
          phone: parts[1] ?? '',
          group: parts[2] ?? 'Famille',
          isFavorite: parts[3] == 'true',
        ));
      }
    }
    try {
      // Persist imported contacts and collect with assigned IDs
      for (var c in imported) {
        final id = await _dbHelper.insertContact(c);
        c.id = id;
      }
      setState(() {
        contacts.addAll(imported);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import CSV')));
    }
  }

  Future<void> _toggleFavorite(Contact contact) async {
    setState(() {
      contact.isFavorite = !contact.isFavorite;
    });
    if (contact.id != null) {
      try {
        await _dbHelper.updateContact(contact);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la mise à jour')));
      }
    }
  }

  Future<void> _openEditContactForm(int index) async {
    final contact = contacts[index];
    final result = await Navigator.of(context).push<Contact>(
        MaterialPageRoute(builder: (_) => ContactFormScreen(contact: contact)));
    if (result != null) {
      try {
        await _dbHelper.updateContact(result);
        setState(() {
          contacts[index] = result;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur lors de la mise à jour du contact')));
      }
    }
  }

  Future<void> _confirmDeleteContact(int index) async {
    final contact = contacts[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le contact'),
        content: Text('Voulez-vous vraiment supprimer ${contact.name} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;

    // remove locally first
    setState(() {
      contacts.removeAt(index);
    });

    try {
      if (contact.id != null) await _dbHelper.deleteContact(contact.id!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contact supprimé'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () async {
            // undo: reinsert contact
            try {
              final newId = await _dbHelper.insertContact(contact);
              contact.id = newId;
              setState(() => contacts.insert(index, contact));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Impossible d\'annuler la suppression')));
            }
          },
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression')));
    }
  }

  Future<void> _openAddContactForm() async {
    final result = await Navigator.of(context)
        .push<Contact>(MaterialPageRoute(builder: (_) => ContactFormScreen()));
    if (result != null) {
      try {
        final id = await _dbHelper.insertContact(result);
        result.id = id;
        setState(() => contacts.add(result));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = contacts.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              c.phone.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesGroup = selectedGroup == 'Tous' || c.group == selectedGroup;
      return matchesSearch && matchesGroup;
    }).toList();

    final groups = ['Tous', 'Famille', 'Amis', 'Travail'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Exporter CSV',
            onPressed: () async {
              final csv = contactsToCsv();
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Exporter CSV'),
                  content: SingleChildScrollView(child: SelectableText(csv)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'))
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.upload),
            tooltip: 'Importer CSV',
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform
                  .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                final csvContent = await file.readAsString();
                await importContactsFromCsv(csvContent);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Contacts importés depuis le fichier CSV.')),
                );
              }
            },
          ),
          PopupMenuButton<ThemeMode>(
            icon: Icon(Icons.brightness_6),
            tooltip: 'Changer le mode',
            onSelected: (mode) {
              // Theme mode is now managed by main.dart via callback
              if (widget.onThemeModeChanged != null) {
                widget.onThemeModeChanged!(mode);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Clair'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Sombre'),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('Système'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedGroup,
                  items: groups
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedGroup = val);
                  },
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortMode,
                  items: [
                    DropdownMenuItem(value: 'name_asc', child: Text('Nom ↑')),
                    DropdownMenuItem(value: 'name_desc', child: Text('Nom ↓')),
                    DropdownMenuItem(
                        value: 'favorite_first', child: Text('Favoris')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sortMode = v);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: (() {
                // apply sort
                List<Contact> sorted = filteredContacts.toList();
                if (_sortMode == 'name_asc') {
                  sorted.sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                } else if (_sortMode == 'name_desc') {
                  sorted.sort((a, b) =>
                      b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                } else if (_sortMode == 'favorite_first') {
                  sorted.sort((a, b) =>
                      (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
                }

                final int maxItems = _pageSize * _currentPage;
                final displayed = sorted.take(maxItems).toList();

                if (displayed.isEmpty)
                  return Center(child: Text('Aucun contact.'));

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (context, index) {
                          final contact = displayed[index];
                          return ListTile(
                            leading: contact.avatarPath != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        FileImage(File(contact.avatarPath!)))
                                : CircleAvatar(
                                    child: Text(contact.name.isNotEmpty
                                        ? contact.name[0]
                                        : '?')),
                            title: Text(contact.name),
                            subtitle:
                                Text('${contact.phone} • ${contact.group}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    contact.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: contact.isFavorite
                                        ? Colors.pink
                                        : Colors.grey,
                                  ),
                                  tooltip: contact.isFavorite
                                      ? 'Retirer des favoris'
                                      : 'Ajouter aux favoris',
                                  onPressed: () => _toggleFavorite(contact),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  tooltip: 'Modifier',
                                  onPressed: () => _openEditContactForm(
                                      contacts.indexOf(contact)),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _confirmDeleteContact(
                                      contacts.indexOf(contact)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (sorted.length > displayed.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: () => setState(() => _currentPage++),
                          child: Text('Charger plus'),
                        ),
                      ),
                  ],
                );
              })(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddContactForm,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un contact',
      ),
    );
  }
}
