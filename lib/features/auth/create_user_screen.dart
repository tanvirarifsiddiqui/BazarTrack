import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/created_profile_screen.dart';
import 'package:flutter_boilerplate/features/auth/widget/auth_header.dart';
import 'package:flutter_boilerplate/features/finance/controller/finance_controller.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:get/get.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_button.dart'; // <- custom button
import '../../base/custom_snackbar.dart';
import '../../util/dimensions.dart';
import '../dashboard/controller/analytics_controller.dart';
import 'controller/auth_controller.dart';
import 'model/role.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Role (nullable)
  UserRole? _selectedRole;

  // Visibility toggles for password fields
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Focus nodes for smooth keyboard navigation
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

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
                  // Header
                  const AuthHeader('Create New User'),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(
                        children: [
                          // Name field
                          TextFormField(
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Email field
                          TextFormField(
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
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
                          const SizedBox(height: 14),

                          // Password field with eye icon
                          TextFormField(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword ? 'Show' : 'Hide',
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirm password field with eye icon + matching validation
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            focusNode: _confirmFocus,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirm ? 'Show' : 'Hide',
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Role dropdown
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: UserRole.values.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r.toApi().capitalizeFirst!),
                              );
                            }).toList(),
                            onChanged: (r) => setState(() => _selectedRole = r),
                            validator: (v) => v == null ? 'Please select a role' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Use your custom button (adjust properties if your CustomButton signature is different)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      buttonText: 'Create User',
                      icon: Icons.person_add,
                      // isLoading: authCtrl.isCreatingUser.value,
                      onPressed: authCtrl.isCreatingUser.value
                          ? null
                          : () => _onSubmit(authCtrl, context),
                      // If your CustomButton uses another param name, change accordingly
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

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final role = _selectedRole!;

    final created = await authCtrl.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    if (created != null) {
      // Clear form
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      setState(() => _selectedRole = null);

      _confirmPasswordCtrl.clear();
      // Show success and navigate
      Get.off(() => CreatedProfileScreen(createdUser: created));
      showCustomSnackBar('User ${created.name} created', isError: false);
      Get.find<AnalyticsController>().loadDashboardUserInfo();
      if(created.role == UserRole.assistant){
        Get.find<OrderController>().getAllAssistants();
        Get.find<FinanceController>().loadAssistants();
      }
    }
  }
}
