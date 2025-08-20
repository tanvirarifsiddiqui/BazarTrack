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
      MonthlyCount(month: '2025-08', count: 43),
    ],
    revenueByMonth: [
      MonthlyRevenue(month: '2025-01', revenue: 75.00),
      MonthlyRevenue(month: '2025-02', revenue: 120.50),
      MonthlyRevenue(month: '2025-03', revenue: 300.00),
      MonthlyRevenue(month: '2025-04', revenue: 210.25),
      MonthlyRevenue(month: '2025-05', revenue: 450.00),
      MonthlyRevenue(month: '2025-08', revenue: 1878.00),
    ],
  );

  const ReportsSummary({
    Key? key,
    required this.reports,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return ReportsChartSyncfusion.fromReportsData(reports, theme);
    return ReportsChartSyncfusion.fromReportsData(_dummyReports, theme);
  }

}
