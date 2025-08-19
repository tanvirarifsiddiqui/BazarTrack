// lib/features/dashboard/components/reports_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/components/reports_chart.dart';
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
    return ReportsChart.fromReportsData(reports, theme);
  }

}
