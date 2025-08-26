
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';

import 'colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.accent),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
      borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
    ),
    floatingLabelStyle: TextStyle(
      color: AppColors.primary,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primary, // cursor color
    selectionColor: AppColors.primary.withValues(alpha: 0.3), // optional
    selectionHandleColor: AppColors.primary, // handle color
  ),

);