import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/components/reports_chart.dart';
import '../model/monthly_report.dart';

class ReportsSummary extends StatelessWidget {
  final ReportsData reports;
  final ThemeData theme;

  // todo: just for testing, have to remove it later.
  static final ReportsData _dummyReports = ReportsData(
    ordersByMonth: [
      MonthlyCount(month: '2025-01', count: 2),
      MonthlyCount(month: '2025-02', count: 5),
      MonthlyCount(month: '2025-03', count: 8),
      MonthlyCount(month: '2025-04', count: 6),
      MonthlyCount(month: '2025-05', count: 10),
      MonthlyCount(month: '2025-08', count: 22),
    ],
    expenseByMonth: [
      MonthlyResponse(month: '2025-01', expense: 75.00),
      MonthlyResponse(month: '2025-02', expense: 120.50),
      MonthlyResponse(month: '2025-03', expense: 300.00),
      MonthlyResponse(month: '2025-04', expense: 210.25),
      MonthlyResponse(month: '2025-05', expense: 440.00),
      MonthlyResponse(month: '2025-08', expense: 943.00),
    ],
  );

  const ReportsSummary({
    Key? key,
    required this.reports,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportsChartSyncfusion.fromReportsData(reports, theme);
    // return ReportsChartSyncfusion.fromReportsData(_dummyReports, theme);
  }

}
