import 'package:flutter/material.dart';

import '../util/colors.dart';

class SquareBadge extends StatelessWidget {
  final IconData? icon;
  final String? symbol;

  const SquareBadge({super.key,
    this.icon,
    this.symbol,
  })  : assert(icon != null || symbol != null, 'Provide icon or symbol');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 18, color: AppColors.primary)
          : Text(
        symbol!,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}