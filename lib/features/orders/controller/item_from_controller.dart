import 'package:flutter/material.dart';

class ItemFormControllers {
  final TextEditingController productName = TextEditingController();
  final TextEditingController quantity    = TextEditingController(text: '1');
  final TextEditingController unit        = TextEditingController(text: 'pcs');
  final TextEditingController estimatedCost = TextEditingController();

  void dispose() {
    productName.dispose();
    quantity.dispose();
    unit.dispose();
    estimatedCost.dispose();
  }
}
