import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_text_field.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:flutter_boilerplate/features/auth/signup_screen.dart';
import 'package:flutter_boilerplate/data/model/user/role.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                focusNode: _emailFocus,
                nextFocus: _passwordFocus,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                focusNode: _passwordFocus,
                isPassword: true,
                inputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              CustomButton(
                buttonText: 'Login',
                onPressed: () async {
                  await Get.find<AuthController>().login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  final user = Get.find<AuthController>().currentUser;
                  if (user?.role == UserRole.owner) {
                    Get.offAll(const OwnerDashboard());
                  } else {
                    Get.offAll(const AssistantDashboard());
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Get.to(const SignUpScreen());
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
