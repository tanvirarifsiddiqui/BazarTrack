import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

class AppInputDecorations {
  static InputDecoration generalInputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon, String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary,) : null,
      prefixText: prefixText,
      prefixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
        borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
