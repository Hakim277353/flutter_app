# Carnet de Contacts Flutter

A professional Flutter app for managing contacts with authentication, groups, favorites, dark mode, and CSV import/export.

## Quick Start

```powershell
cd flutter_app
flutter pub get
flutter run
```

## Features

- Email/password authentication
- Contact list with search and group filter
- Add, edit, delete contacts
- Mark contacts as favorites
- Import/export contacts (CSV)
- Manual dark mode toggle
- Form validation
- Material Design UI
- Local persistence with SQLite (`sqflite`) for contacts
- Avatar (image) support for contacts (stored as local file paths)

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                # App entry point, theme, routing
│   ├── models/
│   │   └── contact.dart         # Contact model
│   └── screens/
│       ├── login_screen.dart    # Login screen
│       ├── register_screen.dart # Registration screen
│       └── contact_list_screen.dart # Main contact list UI
├── pubspec.yaml                 # Dependencies
└── README.md                    # Documentation
```

## Requirements

- Flutter SDK (https://flutter.dev/docs/get-started/install)
- Dart 2.18+
- Android emulator, iOS simulator, or physical device

## Usage

1. Run the app with `flutter run`.
2. Register or log in.
3. Add, edit, delete, and favorite contacts.
4. Use the search and group filter to find contacts.
5. Import/export contacts using CSV.
6. Toggle dark mode from the contact list screen.
7. Contacts are stored locally using SQLite. The database file is located in the app's documents/databases folder on the device (managed by `sqflite`).
8. When adding or editing a contact you can tap the avatar to pick an image from the device; the app stores the picked file path in the database.

Notes and troubleshooting:
- Run `flutter pub get` after pulling updates to fetch `sqflite` and `path` packages.
- If you previously ran the app before this update, the database will be upgraded automatically to add the `avatar_path` column.
- If you see issues with image display, ensure the app has permission to access storage on the device/emulator.

## Contributing

Pull requests and suggestions are welcome!

## License

[MIT](LICENSE)
