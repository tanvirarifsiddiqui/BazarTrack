import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/model/user.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';

class CreatedProfileScreen extends StatelessWidget {
  final UserModel createdUser;
  const CreatedProfileScreen({Key? key, required this.createdUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final authCtrl = Get.find<AuthController>();
    // final isOwner = authCtrl.user.value?.role == UserRole.owner;
    final user = createdUser;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context, user.name, user.role.name),
              const SizedBox(height: 24),

              // Contact Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(Dimensions.radiusDefault),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: user.name,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Role',
                        value: user.role.name.capitalizeFirst ?? '',
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        )
    );
  }

  Widget _buildHeader(BuildContext context, String name, String role) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Profile avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '',
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            role.capitalizeFirst ?? '',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
