/// Main entry point for the Contact App.
/// Handles theme, routing, and global configuration.
/// Author: [Your Name]
/// Date: 2025-11-17
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/contact_list_screen.dart';
import 'screens/register_screen.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Mon App d\'Authentification',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/contacts': (context) => ContactListScreen(
                  onThemeModeChanged: (newMode) {
                    themeModeNotifier.value = newMode;
                  },
                ),
          },
        );
      },
    );
  }
}
