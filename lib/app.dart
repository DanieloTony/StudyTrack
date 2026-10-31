import 'package:flutter/material.dart';

import 'app/main_screen.dart';
import 'theme/app_theme.dart';

class StudyTrackApp extends StatefulWidget {
  const StudyTrackApp({super.key});

  @override
  State<StudyTrackApp> createState() => _StudyTrackAppState();
}

class _StudyTrackAppState extends State<StudyTrackApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (value) {
          setState(() => _isDarkMode = value);
        },
      ),
    );
  }
}
