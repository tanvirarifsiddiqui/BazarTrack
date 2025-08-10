/*
// Title: Assistant Wallet Summary
// Description: Wallet Summary For paid out, pending, refunds
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 10:22 AM
*/
import 'package:flutter/material.dart';

/// 2. Assistant Wallet Summary
class WalletSummary extends StatelessWidget {
  final ThemeData theme;
  const WalletSummary(this.theme);

  @override
  Widget build(BuildContext context) {
    final textTheme = theme.textTheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assistant Wallet', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Balance:', style: textTheme.titleMedium),
                const SizedBox(width: 8),
                Text(
                  '\$1,245.00',
                  style: textTheme.headlineSmall?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _WalletStat('Paid Out', '৳ 3,200', Icons.attach_money),
                _WalletStat('Pending', '৳ 560', Icons.hourglass_empty),
                _WalletStat('Refunds', '৳ 120', Icons.refresh),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  const _WalletStat(this.label, this.amount, this.icon);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(amount, style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}