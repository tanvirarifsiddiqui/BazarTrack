
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/components/reports_chart.dart';
import '../model/assistant_analytics.dart';

class AssistantReportsChart extends StatelessWidget {
  final AssistantAnalytics data;
  final ThemeData theme;

  const AssistantReportsChart({
    Key? key,
    required this.data,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportsChart.fromAssistantAnalytics(data, theme);

  }
}
