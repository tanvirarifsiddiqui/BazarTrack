
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/components/reports_chart.dart';
import '../model/assistant_analytics.dart';
import '../model/monthly_report.dart';

class AssistantReportsChart extends StatelessWidget {
  final AssistantAnalytics data;
  final ThemeData theme;

  // todo: just for testing, have to remove it later.
  static final AssistantAnalytics _dummyAssistantAnalytics = AssistantAnalytics(
    totalOrders: 16,
    totalRevenue: 1204.0,
    ordersByMonth: [
      MonthlyCount(month: '2025-01', count: 1),
      MonthlyCount(month: '2025-02', count: 3),
      MonthlyCount(month: '2025-03', count: 2),
      MonthlyCount(month: '2025-04', count: 3),
      MonthlyCount(month: '2025-05', count: 5),
      MonthlyCount(month: '2025-08', count: 15),
    ],
    revenueByMonth: [
      MonthlyRevenue(month: '2025-01', revenue: 50.00),
      MonthlyRevenue(month: '2025-02', revenue: 150.00),
      MonthlyRevenue(month: '2025-03', revenue: 100.00),
      MonthlyRevenue(month: '2025-04', revenue: 170.00),
      MonthlyRevenue(month: '2025-05', revenue: 200.00),
      MonthlyRevenue(month: '2025-08', revenue: 1154.00),
    ],
  );


  const AssistantReportsChart({
    Key? key,
    required this.data,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportsChartSyncfusion.fromAssistantAnalytics(data, theme);
    // return ReportsChartSyncfusion.fromAssistantAnalytics(_dummyAssistantAnalytics, theme);

  }
}
