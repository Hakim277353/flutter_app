/// Contact model representing a single contact entry.
/// Includes name, phone, group, and favorite status.
/// Date: 2025-11-17
class Contact {
  int? id;
  String name;
  String phone;
  String group;
  bool isFavorite;
  String? avatarPath;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.group = 'Général',
    this.isFavorite = false,
    this.avatarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'group_name': group,
      'is_favorite': isFavorite ? 1 : 0,
      'avatar_path': avatarPath,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      group: map['group_name'] as String? ?? 'Général',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      avatarPath: map['avatar_path'] as String?,
    );
  }

  /// Simple validation helpers
  String? validateName() {
    if (name.trim().isEmpty) return 'Le nom ne doit pas être vide.';
    return null;
  }

  String? validatePhone() {
    final phoneRegex = RegExp(r'^[0-9+\- ]{6,}$');
    if (!phoneRegex.hasMatch(phone)) return 'Numéro de téléphone invalide.';
    return null;
  }
}
