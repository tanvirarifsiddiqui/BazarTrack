/*
// Title: Stats Summary
// Description: Total Orders, Assigned, In Progress, Completed
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 9:55 AM
*/
import 'package:flutter/material.dart';

/// 1. Stats Summary: Total, Assigned, In Progress, Completed
class StatsSummary extends StatelessWidget {
  final ThemeData theme;
  const StatsSummary(this.theme);

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTile('Total Orders', '128', Icons.list_alt, theme.primaryColor),
      _StatTile('Assigned', '76', Icons.person_add, Colors.orange),
      _StatTile('In Progress', '32', Icons.autorenew, Colors.blue),
      _StatTile('Completed', '20', Icons.check_circle, Colors.green),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: stats,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}