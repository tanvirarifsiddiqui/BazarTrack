import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: Color(0xFFdcb247),
  secondaryHeaderColor: Color(0xFF1ED7AA),
  disabledColor: Color(0xFFBABFC4),
  brightness: Brightness.light,
  hintColor: Color(0xFF9F9F9F),
  cardColor: Colors.white,
  colorScheme: ColorScheme.light(primary: Color(0xFFdcb247), secondary: Color(0xFFdcb247), surface: Color(0xFFF3F3F3), error: Color(0xFFE84D4F)),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Color(0xFFdcb247))),
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);