import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Models used by your project
import '../model/assistant_analytics.dart';
import '../model/monthly_report.dart';

/// Reusable reports chart widget that displays orders (bar) and revenue (line)
/// stacked vertically, with a structured table/summary below the charts.
///
/// Provides convenient factories to construct from your existing models
/// (AssistantAnalytics and ReportsData).
class ReportsChart extends StatelessWidget {
  final List<String> months;
  final List<int> orders;
  final List<double> revenue;
  final ThemeData theme;

  /// If true, the widget renders a combined DataTable below the charts
  final bool showTableBelow;

  /// Optional custom widget to display below charts (used instead of the table)
  final Widget? customBelow;

  const ReportsChart._({
    Key? key,
    required this.months,
    required this.orders,
    required this.revenue,
    required this.theme,
    this.showTableBelow = true,
    this.customBelow,
  }) : super(key: key);

  /// Build from AssistantAnalytics
  factory ReportsChart.fromAssistantAnalytics(AssistantAnalytics data, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final monthsList = _unionMonths(
      data.ordersByMonth.map((e) => e.month).toList(),
      data.revenueByMonth.map((e) => e.month).toList(),
    );

    final idxMap = {for (var i = 0; i < monthsList.length; i++) monthsList[i]: i};

    final orders = List<int>.generate(monthsList.length, (i) => 0);
    for (final m in data.ordersByMonth) {
      final idx = idxMap[m.month] ?? 0;
      orders[idx] = m.count;
    }

    final revenue = List<double>.generate(monthsList.length, (i) => 0.0);
    for (final r in data.revenueByMonth) {
      final idx = idxMap[r.month] ?? 0;
      revenue[idx] = r.revenue.toDouble();
    }

    return ReportsChart._(
      months: monthsList,
      orders: orders,
      revenue: revenue,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  /// Build from ReportsData (the owner report structure)
  factory ReportsChart.fromReportsData(ReportsData reports, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final monthsList = _unionMonths(
      reports.ordersByMonth.map((e) => e.month).toList(),
      reports.revenueByMonth.map((e) => e.month).toList(),
    );

    final idxMap = {for (var i = 0; i < monthsList.length; i++) monthsList[i]: i};

    final orders = List<int>.generate(monthsList.length, (i) => 0);
    for (final m in reports.ordersByMonth) {
      final idx = idxMap[m.month] ?? 0;
      orders[idx] = m.count;
    }

    final revenue = List<double>.generate(monthsList.length, (i) => 0.0);
    for (final r in reports.revenueByMonth) {
      final idx = idxMap[r.month] ?? 0;
      revenue[idx] = r.revenue.toDouble();
    }

    return ReportsChart._(
      months: monthsList,
      orders: orders,
      revenue: revenue,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  // --- Helpers ---
  static List<String> _unionMonths(List<String> a, List<String> b) {
    final out = <String>[];
    for (final s in a) {
      if (!out.contains(s)) out.add(s);
    }
    for (final s in b) {
      if (!out.contains(s)) out.add(s);
    }
    return out;
  }

  List<String> _monthLabels(List<String> months) {
    return months.map((m) {
      if (m.length <= 4) return m;
      try {
        final parsed = DateFormat('yyyy-MM').parseLoose(m);
        return DateFormat.MMM().format(parsed);
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
    final labels = _monthLabels(months);
    final textSmall = theme.textTheme.bodySmall;
    final duration = const Duration(milliseconds: 400);

    // Build bar groups
    final barGroups = List.generate(months.length, (i) {
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: orders[i].toDouble(),
          width: 18,
          borderRadius: BorderRadius.circular(6),
          color: theme.colorScheme.primary,
        )
      ]);
    });

    final spots = List.generate(months.length, (i) => FlSpot(i.toDouble(), revenue[i]));

    final maxOrder = orders.isNotEmpty ? orders.reduce((a, b) => a > b ? a : b).toDouble() : 0.0;
    final maxRevenue = revenue.isNotEmpty ? revenue.reduce((a, b) => a > b ? a : b) : 0.0;

    final orderTop = (maxOrder * 1.2).clamp(5.0, double.infinity);
    final revenueTop = (maxRevenue * 1.2).clamp(5.0, double.infinity);

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
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitleWidget(value, meta, labels, textSmall),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: true),
              ),
              duration: duration,
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
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    ),
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
                      getTitlesWidget: (value, meta) =>
                          _bottomTitleWidget(value, meta, labels, textSmall),
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

        const SizedBox(height: 16),

        // Structured information below the chart: either custom widget or auto table
        if (customBelow != null) ...[
          customBelow!,
        ] else if (showTableBelow) ...[
          const SizedBox(height: 8),
          _buildCombinedTable(),
        ],
      ],
    );
  }

  Widget _buildCombinedTable() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Orders')),
        DataColumn(label: Text('Revenue')),
      ],
      rows: List.generate(months.length, (i) {
        return DataRow(cells: [
          DataCell(Text(months[i])),
          DataCell(Text(orders[i].toString())),
          DataCell(Text(formatter.format(revenue[i]))),
        ]);
      }),
    );
  }
}
