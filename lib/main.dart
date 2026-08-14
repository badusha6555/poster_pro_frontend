import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posterpro/screens/home/home_screen.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: PosterProApp()));
}

class PosterProApp extends StatelessWidget {
  const PosterProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosterPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
