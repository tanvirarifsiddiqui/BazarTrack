// lib/features/dashboard/components/reports_summary.dart

import 'package:flutter/material.dart';
import '../model/monthly_report.dart';

class ReportsSummary extends StatelessWidget {
  final ReportsData reports;
  final ThemeData theme;

  const ReportsSummary({
    Key? key,
    required this.reports,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Orders by Month', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildOrdersTable(),

        const SizedBox(height: 24),

        Text('Revenue by Month', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildRevenueTable(),
      ],
    );
  }

  Widget _buildOrdersTable() {
    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Count')),
      ],
      rows: reports.ordersByMonth.map((m) {
        return DataRow(cells: [
          DataCell(Text(m.month)),
          DataCell(Text(m.count.toString())),
        ]);
      }).toList(),
    );
  }

  Widget _buildRevenueTable() {
    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Revenue')),
      ],
      rows: reports.revenueByMonth.map((r) {
        return DataRow(cells: [
          DataCell(Text(r.month)),
          DataCell(Text('\$${r.revenue.toStringAsFixed(2)}')),
        ]);
      }).toList(),
    );
  }
}
