/*
// Title: Stats Summary
// Description: Total Orders, Assigned, In Progress, Completed
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 9:55 AM
*/
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/colors.dart';

import '../../../base/price_format.dart';

class StatsSummary extends StatelessWidget {
  final int totalOrders;
  final int totalUsers;
  final int totalPayments;
  final double balance;
  final ThemeData theme;

  const StatsSummary({
    Key? key,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalPayments,
    required this.balance,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTile('Total Orders', totalOrders.toString(), Icons.shopping_cart, AppColors.primary,),
      _StatTile('Users', totalUsers.toString(), Icons.group, Colors.orange,),
      _StatTile('Total Payments', totalPayments.toString(), Icons.payments, Colors.teal,),
      _StatTile('Total Revenue', '${formatPrice(balance)}', Icons.account_balance_wallet, Colors.green,),
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

// _StatTile unchanged from above

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
                    title,
                    style: textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: textTheme.titleMedium,
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