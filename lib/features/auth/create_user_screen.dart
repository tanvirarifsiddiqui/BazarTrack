// lib/features/auth/screens/create_user_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/custom_app_bar.dart';
import '../../util/colors.dart';
import '../../util/dimensions.dart';
import 'controller/auth_controller.dart';
import 'model/role.dart';

class CreateUserPage extends StatelessWidget {
  CreateUserPage({Key? key}) : super(key: key);

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _role         = Rxn<UserRole>();

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Create New User'),
      body: SafeArea(
        child: Obx(() {
          if (!authCtrl.isOwner) {
            return const Center(child: Text('Only owners can add users.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Role dropdown
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role.value,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    items: UserRole.values.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.toApi().capitalizeFirst!),
                      );
                    }).toList(),
                    onChanged: (r) => _role.value = r,
                    validator: (v) =>
                    v == null ? 'Please select a role' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authCtrl.isCreatingUser.value
                          ? null
                          : () => _onSubmit(authCtrl, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authCtrl.isCreatingUser.value
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                          : const Text(
                        'Create User',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _onSubmit(AuthController authCtrl, BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final role     = _role.value!;

    final created = await authCtrl.createUser(
      name:     name,
      email:    email,
      password: password,
      role:     role,
    );

    if (created != null) {
      // Clear form
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _role.value = null;

      // Show success and navigate back
      Get.snackbar('Success', 'User ${created.name} created',
          snackPosition: SnackPosition.BOTTOM);
      Get.back();
    }
  }
}
