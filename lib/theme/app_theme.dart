import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F6E56);
  static const Color backgroundColor = Color(0xFF0F1117);
  static const Color cardColor = Color(0xFF161D18);
  static const Color textColor = Color(0xFFF0F0F0);
  
  static const Color statusEntered = Color(0xFF1D9E75);
  static const Color statusExited = Color(0xFFA32D2D);
  static const Color statusPending = Color(0xFF854F0B);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: cardColor,
      onSurface: textColor,
    ),
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
  );
}
