import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/contact.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;
  const ContactFormScreen({Key? key, this.contact}) : super(key: key);

  @override
  _ContactFormScreenState createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _group = 'Famille';
  bool _isFavorite = false;
  String? _avatarPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _group = c?.group ?? 'Famille';
    _isFavorite = c?.isFavorite ?? false;
    _avatarPath = c?.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _avatarPath = result.files.single.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image')));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final contact = Contact(
        id: widget.contact?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        group: _group,
        isFavorite: _isFavorite,
        avatarPath: _avatarPath,
      );
      Navigator.of(context).pop(contact);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null
            ? 'Ajouter un contact'
            : 'Modifier le contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? Icon(Icons.camera_alt, size: 36)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Le nom ne doit pas être vide.';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final phoneRegex = RegExp(r'^[0-9+\- ]{6,}$');
                    if (v == null || !phoneRegex.hasMatch(v.trim()))
                      return 'Numéro de téléphone invalide.';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _group,
                  decoration: InputDecoration(labelText: 'Groupe'),
                  items: ['Famille', 'Amis', 'Travail']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _group = val);
                  },
                ),
                SizedBox(height: 12),
                CheckboxListTile(
                  value: _isFavorite,
                  onChanged: (v) => setState(() => _isFavorite = v ?? false),
                  title: Text('Favori'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? CircularProgressIndicator()
                      : Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
