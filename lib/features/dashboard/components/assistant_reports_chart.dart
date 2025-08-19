
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/assistant_analytics.dart';
import 'package:intl/intl.dart';

class AssistantReportsChart extends StatelessWidget {
  final AssistantAnalytics data;
  final ThemeData theme;

  const AssistantReportsChart({
    Key? key,
    required this.data,
    required this.theme,
  }) : super(key: key);

  // Converts dates like "2025-08" to short labels "Aug", otherwise uses first 3 chars
  List<String> _monthLabels(List<String> months) {
    return months.map((m) {
      if (m.length <= 4) return m;
      try {
        // try parse yyyy-MM or yyyy-MM-dd
        final parsed = DateFormat('yyyy-MM').parseLoose(m);
        return DateFormat.MMM().format(parsed); // 'Aug'
      } catch (_) {
        return m.length <= 3 ? m : m.substring(0, 3);
      }
    }).toList();
  }

  Widget _bottomTitleWidget(double value, TitleMeta meta, List<String> labels, TextStyle? style) {
    final idx = value.toInt();
    if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Transform.translate(
        offset: const Offset(0, 6),
        child: Text(labels[idx], style: style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = data.ordersByMonth; // List<MonthlyCount>
    final revenue = data.revenueByMonth; // List<MonthlyRevenue>

    // union preserving order of appearance
    final allMonths = <String>{
      for (final o in orders) o.month,
      for (final r in revenue) r.month,
    }.toList();

    // If union set is empty, fallback to individual lists
    final months = allMonths.isNotEmpty ? allMonths : [
      ...orders.map((e) => e.month),
      ...revenue.map((e) => e.month),
    ];

    final labels = _monthLabels(months);

    // map month -> index
    final idxMap = <String, int>{};
    for (var i = 0; i < months.length; i++) idxMap[months[i]] = i;

    // Prepare bar groups (orders)
    final barGroups = orders.map((mc) {
      final x = (idxMap[mc.month] ?? 0);
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: mc.count.toDouble(), // ensure double
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.primary,
          ),
        ],
      );
    }).toList();

    // Prepare line spots (revenue)
    final spots = revenue.map((mr) {
      final x = (idxMap[mr.month] ?? 0).toDouble();
      return FlSpot(x, mr.revenue.toDouble());
    }).toList();

    // Axis scaling (defensive)
    double maxOrder = 0;
    if (orders.isNotEmpty) {
      maxOrder = orders.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    }
    double maxRevenue = 0;
    if (revenue.isNotEmpty) {
      maxRevenue = revenue.map((e) => e.revenue).reduce((a, b) => a > b ? a : b).toDouble();
    }

    final orderTop = (maxOrder * 1.2).clamp(5.0, double.infinity);
    final revenueTop = (maxRevenue * 1.2).clamp(5.0, double.infinity);

    final textSmall = theme.textTheme.bodySmall;
    final duration = const Duration(milliseconds: 400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Orders by Month', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: orderTop,
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: orderTop / 4,
                      // use default getTitles so no callback here
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => _bottomTitleWidget(value, meta, labels, textSmall),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: true),
              ),
              duration: duration, // prefer duration + curve (deprecated swapAnimationDuration)
              curve: Curves.easeInOut,
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text('Revenue by Month', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: revenueTop,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    barWidth: 3,
                    color: theme.colorScheme.secondary,
                    belowBarData: BarAreaData(show: true, color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
                  ),
                ],
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: revenueTop / 4,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => _bottomTitleWidget(value, meta, labels, textSmall),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(enabled: true),
              ),
              duration: duration,
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ],
    );
  }
}
