import 'package:flutter/material.dart';

class AssistantStatsSummary extends StatelessWidget {
  final int totalOrders;
  final double totalExpense;
  final ThemeData theme;

  const AssistantStatsSummary({
    Key? key,
    required this.totalOrders,
    required this.totalExpense,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTile(
        'Total Orders',
        totalOrders.toString(),
        Icons.shopping_cart,
        theme.primaryColor,
      ),
      _StatTile(
        'Total Expense',
        '৳${totalExpense.toStringAsFixed(2)}',
        Icons.account_balance_wallet,
        Colors.green,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
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
            const SizedBox(width: 10),
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
