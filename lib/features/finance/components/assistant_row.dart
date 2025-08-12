import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssistantRow extends StatelessWidget {
  final dynamic assistant; // replace dynamic with your Assistant model type if available
  final NumberFormat fmt;
  final VoidCallback? onTap;

  const AssistantRow({
    Key? key,
    required this.assistant,
    required this.fmt,
    this.onTap,
  }) : super(key: key);

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final avatarColor = theme.primaryColor;

    // safe read of name and balance
    final name = (assistant.name ?? '').toString();
    final balance = assistant.balance;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: avatarColor.withValues(alpha: 0.12),
        child: Text(
          _initials(name),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            balance != null ? fmt.format(balance) : '-',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),

        ],
      ),
    );
  }
}