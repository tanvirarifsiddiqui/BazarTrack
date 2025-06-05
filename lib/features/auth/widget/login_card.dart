import 'package:flutter/material.dart';
import '../../../base/custom_text_field.dart';

class LoginCard extends StatelessWidget {
  final TextEditingController controller;
  const LoginCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: 'Email',
      inputType: TextInputType.emailAddress,
    );
  }
}
