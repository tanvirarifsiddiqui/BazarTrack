import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [

      CustomTextField(controller: controller, hintText: 'email', focusNode: ),

      CustomTextField(controller: controller, hintText: 'password'),

      CustomButton(buttonText: 'Login'),

    ]);
  }
}
