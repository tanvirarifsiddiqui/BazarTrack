import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_text_field.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/auth/model/user.dart';
import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  UserRole _role = UserRole.owner;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: 'Name',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Radio<UserRole>(
                  value: UserRole.owner,
                  groupValue: _role,
                  onChanged: (val) => setState(() => _role = val!),
                ),
                const Text('Owner'),
                Radio<UserRole>(
                  value: UserRole.assistant,
                  groupValue: _role,
                  onChanged: (val) => setState(() => _role = val!),
                ),
                const Text('Assistant'),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              buttonText: 'Create Account',
              onPressed: () async {
                final user = UserModel(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  role: _role,
                );
                await Get.find<AuthController>().signUp(user);
                if (_role == UserRole.owner) {
                  Get.offAll(const OwnerDashboard());
                } else {
                  Get.offAll(const AssistantDashboard());
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
