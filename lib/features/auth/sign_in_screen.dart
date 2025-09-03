import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_text_field.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/auth/widget/auth_header.dart';
import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
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
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Sign In'),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthHeader('Welcome Back'),
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
                  loading: authController.isLoading.value,   // NEW
                  buttonText: 'Login',
                  onPressed: () async {
                    final success = await authController.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (!success) {
                      Get.snackbar(
                        'Login Failed',
                        'Invalid credentials.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    final user = authController.user.value!;
                    if (user.role == UserRole.owner) {
                      Get.offAll(const OwnerDashboard());
                    } else {
                      Get.offAll(const AssistantDashboard());
                    }
                  },
                ),
                // TextButton(
                //   onPressed: () {
                //     Get.to(const SignUpScreen());
                //   },
                //   child: const Text('Sign Up'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
