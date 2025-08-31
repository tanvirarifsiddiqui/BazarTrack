import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/auth/change_password.dart';
import 'package:flutter_boilerplate/features/auth/create_user_screen.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import '../auth/model/role.dart';

/// Symmetric, modern ProfileScreen replacement.
/// Drop-in replacement for your existing ProfileScreen widget.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: Obx(() {
        final user = authCtrl.user.value;
        if (user == null) {
          return const Center(child: Text("No user data found."));
        }

        final isOwner = user.role == UserRole.owner;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              _HeaderCard(
                name: user.name,
                email: user.email,
                role: user.role.name,
                theme: theme,
              ),

              const SizedBox(height: 36),

              _InfoCard(
                email: user.email,
                // phone: user.phone ?? '-',
                roleLabel: user.role.name.capitalizeFirst ?? '',
              ),

              const SizedBox(height: 36),

              // Action buttons area (symmetric layout)
              Row(
                children: [
                  if (isOwner)...[Expanded(
                    child: CustomButton(
                      // btnColor: AppColors.tertiary,
                      icon: Icons.person_add,
                      buttonText: 'Create User',
                      onPressed: () => Get.to(() => CreateUserPage()),
                    ),
                  ),
                  const SizedBox(width: 12)],
                  Expanded(
                    child: CustomButton(
                      btnColor: AppColors.tertiary,

                      icon: Icons.security,
                      buttonText: 'Change Password',
                      onPressed: () => Get.to(() => ChangePasswordScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Owner-only CTA
                CustomButton(
                  icon: Icons.logout,
                  btnColor: Colors.redAccent,
                  buttonText: 'Logout',
                  loading: authCtrl.isLoading.value,
                  onPressed: () async {
                    await authCtrl.logout();
                    Get.offAllNamed('/login');
                  },
                ),
                const SizedBox(height: 12),


              // Additional symmetric utilities (two-column grid)
              // _UtilityGrid(),

              // const SizedBox(height: 28),

              // Footer small text
              // Text(
              //   'Bazar Track — v1.0',
              //   style: theme.textTheme.bodySmall,
              // ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String? email;
  final String role;
  final ThemeData theme;

  const _HeaderCard({
    Key? key,
    required this.name,
    this.email,
    required this.role,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    num avatarRadius = mathMax(44, width * 0.11);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // background card with gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              )
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Chip(
                      label: Text(role.capitalizeFirst ?? ''),
                      backgroundColor: AppColors.tertiary,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              // small edit icon on right
              // Material(
              //   color: Colors.white.withOpacity(0.06),
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //   child: IconButton(
              //     icon: const Icon(Icons.edit, color: Colors.white),
              //     onPressed: () {
              //       // Hook for future Edit Profile flow
              //     },
              //   ),
              // )
            ],
          ),
        ),

        // avatar that overlaps the card (symmetric center)
        Positioned(
          right: 16,
          bottom: -avatarRadius * 0.45,
          child: _ProfileAvatar(name: name, radius: double.parse(avatarRadius.toString())),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  final String name;
  final double radius;
  const _ProfileAvatar({Key? key, required this.name, required this.radius}) : super(key: key);

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(widget.name);
    return ScaleTransition(
      scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: AppColors.tertiary.withValues(alpha: .7),
        child: CircleAvatar(
          radius: widget.radius - 6,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: TextStyle(fontSize: widget.radius * 0.5, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _InfoCard extends StatelessWidget {
  final String email;
  final String roleLabel;

  const _InfoCard({Key? key, required this.email, required this.roleLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            _InfoTile(icon: Icons.person_outline, title: 'Name', value: Get.find<AuthController>().user.value?.name ?? '-'),
            const Divider(),
            _InfoTile(icon: Icons.email_outlined, title: 'Email', value: email),
            const Divider(),
            // _InfoTile(icon: Icons.phone_android, title: 'Phone', value: phone),
            // const Divider(),
            _InfoTile(icon: Icons.badge_outlined, title: 'Role', value: roleLabel),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({Key? key, required this.icon, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 2,
          child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }
}

class _UtilityGrid extends StatelessWidget {
  const _UtilityGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      _UtilityItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () => Get.toNamed('/help')),
      _UtilityItem(icon: Icons.settings, label: 'Settings', onTap: () => Get.toNamed('/settings')),
      _UtilityItem(icon: Icons.privacy_tip_outlined, label: 'Privacy', onTap: () => Get.toNamed('/privacy')),
      _UtilityItem(icon: Icons.description_outlined, label: 'Terms', onTap: () => Get.toNamed('/terms')),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: tiles,
        ),
      ),
    );
  }
}

class _UtilityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilityItem({Key? key, required this.icon, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Icon(icon, size: 18, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// small helpers
num mathMax(num a, num b) => a > b ? a : b;
