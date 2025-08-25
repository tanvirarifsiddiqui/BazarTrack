
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
    totalExpense: 1204.0,
    ordersByMonth: [
      MonthlyCount(month: '2025-01', count: 1),
      MonthlyCount(month: '2025-02', count: 3),
      MonthlyCount(month: '2025-03', count: 2),
      MonthlyCount(month: '2025-04', count: 3),
      MonthlyCount(month: '2025-05', count: 5),
      MonthlyCount(month: '2025-08', count: 15),
    ],
    expenseByMonth: [
      MonthlyResponse(month: '2025-01', expense: 50.00),
      MonthlyResponse(month: '2025-02', expense: 150.00),
      MonthlyResponse(month: '2025-03', expense: 100.00),
      MonthlyResponse(month: '2025-04', expense: 170.00),
      MonthlyResponse(month: '2025-05', expense: 200.00),
      MonthlyResponse(month: '2025-08', expense: 1154.00),
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
