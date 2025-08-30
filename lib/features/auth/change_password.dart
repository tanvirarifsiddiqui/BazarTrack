// lib/features/auth/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import '../../base/custom_snackbar.dart';
import 'controller/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Change Password'),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.scaffoldPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Current Password
                _buildPasswordField(
                  controller: _currentCtrl,
                  label: 'Current Password',
                  showText: _showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                ),
                const SizedBox(height: 16),

                // New Password
                _buildPasswordField(
                  controller: _newCtrl,
                  label: 'New Password',
                  showText: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
                const SizedBox(height: 16),

                // Confirm New Password
                _buildPasswordField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  showText: _showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    loading: authCtrl.isLoading.value,
                    onPressed:
                        authCtrl.isLoading.value
                            ? null
                            : () => _onSubmit(authCtrl),
                    buttonText: 'Update Password',
                    icon: Icons.security,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(showText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return '$label is required';
        }
        if (label == 'Confirm Password' && v != _newCtrl.text) {
          return 'Passwords do not match';
        }
        if (label == 'New Password' && v.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Future<void> _onSubmit(AuthController authCtrl) async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentCtrl.text.trim();
    final fresh = _newCtrl.text.trim();

    final success = await authCtrl.changePassword(
      currentPassword: current,
      newPassword: fresh,
    );

    if (success) {
      // clear form
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      Get.back();
      showCustomSnackBar('Password updated successfully', isError: false);
    }
  }
}
