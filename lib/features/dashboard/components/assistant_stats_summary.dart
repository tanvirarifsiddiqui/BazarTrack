import 'package:flutter/material.dart';

class AssistantStatsSummary extends StatelessWidget {
  final int totalOrders;
  final double totalRevenue;
  final ThemeData theme;

  const AssistantStatsSummary({
    Key? key,
    required this.totalOrders,
    required this.totalRevenue,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Total Orders',
          value: totalOrders.toString(),
          color: theme.primaryColor,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total Revenue',
          value: totalRevenue.toStringAsFixed(2),
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Text(value, style: txt.titleLarge?.copyWith(color: color)),
              const SizedBox(height: 4),
              Text(label, style: txt.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
