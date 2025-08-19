// lib/features/dashboard/components/reports_chart_syncfusion.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../model/assistant_analytics.dart';
import '../model/monthly_report.dart';

/// Reusable Syncfusion chart widget showing:
/// - Orders as ColumnSeries (primary Y axis)
/// - Revenue as LineSeries (secondary Y axis)
/// X axis displays months formatted like "Aug 2025".
class ReportsChartSyncfusion extends StatelessWidget {
  final List<_ChartPoint> data;
  final ThemeData theme;
  final bool showTableBelow;
  final Widget? customBelow;

  const ReportsChartSyncfusion._({
    Key? key,
    required this.data,
    required this.theme,
    this.showTableBelow = true,
    this.customBelow,
  }) : super(key: key);

  /// Factory: build from your AssistantAnalytics model
  factory ReportsChartSyncfusion.fromAssistantAnalytics(
      AssistantAnalytics analytics, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final points = _mergeMonthlyData(
      analytics.ordersByMonth,
      analytics.revenueByMonth,
    );
    return ReportsChartSyncfusion._(
      data: points,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  /// Factory: build from ReportsData (owner)
  factory ReportsChartSyncfusion.fromReportsData(
      ReportsData reports, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final points = _mergeMonthlyData(
      reports.ordersByMonth,
      reports.revenueByMonth,
    );
    return ReportsChartSyncfusion._(
      data: points,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM yyyy'); // -> "Aug 2025"

    // defensive: empty view
    if (data.isEmpty) {
      return Center(
        child: Text('No data available', style: theme.textTheme.bodyMedium),
      );
    }

    // Compute nice axis ranges (small padding)
    final maxOrders = data.map((e) => e.orders).fold<int>(0, (a, b) => a > b ? a : b);
    final maxRevenue = data.map((e) => e.revenue).fold<double>(0.0, (a, b) => a > b ? a : b);
    final orderTop = (maxOrders * 1.2).clamp(5.0, double.infinity);
    final revenueTop = (maxRevenue * 1.2).clamp(5.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart
        SizedBox(
          height: 360,
          child: SfCartesianChart(
            legend: Legend(isVisible: true, position: LegendPosition.top),
            tooltipBehavior: TooltipBehavior(enable: true, header: ''),
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.months,
              // show label like "Aug 2025"
              dateFormat: dateFmt,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              majorGridLines: const MajorGridLines(width: 0.5),
            ),
            primaryYAxis: NumericAxis(
              name: 'ordersAxis',
              title: AxisTitle(text: 'Orders'),
              minimum: 0,
              maximum: orderTop,
              interval: (orderTop / 4).ceilToDouble(),
              opposedPosition: false,
            ),
            axes: <ChartAxis>[
              NumericAxis(
                name: 'revenueAxis',
                title: AxisTitle(text: 'Revenue'),
                minimum: 0,
                maximum: revenueTop,
                interval: (revenueTop / 4),
                opposedPosition: true,
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
              ),
            ],

            // <-- Corrected series type here -->
            series: <CartesianSeries<_ChartPoint, DateTime>>[
              ColumnSeries<_ChartPoint, DateTime>(
                dataSource: data,
                xValueMapper: (pt, _) => pt.month,
                yValueMapper: (pt, _) => pt.orders,
                name: 'Orders',
                width: 0.6,
                dataLabelSettings: const DataLabelSettings(isVisible: false),
                enableTooltip: true,
                color: theme.colorScheme.primary,
              ),

              LineSeries<_ChartPoint, DateTime>(
                dataSource: data,
                xValueMapper: (pt, _) => pt.month,
                yValueMapper: (pt, _) => pt.revenue,
                yAxisName: 'revenueAxis',
                name: 'Revenue',
                markerSettings: MarkerSettings(isVisible: true),
                enableTooltip: true,
                width: 2,
                color: theme.colorScheme.secondary,
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              ),
            ],
            zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true),
          ),
        ),

        const SizedBox(height: 12),

        // Structured info below (custom or auto table)
        if (customBelow != null) ...[
          customBelow!,
        ] else if (showTableBelow) ...[
          _buildCombinedTable(dateFmt),
        ],
      ],
    );
  }

  Widget _buildCombinedTable(DateFormat dateFmt) {
    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Orders')),
        DataColumn(label: Text('Revenue')),
      ],
      rows: data.map((pt) {
        return DataRow(cells: [
          DataCell(Text(dateFmt.format(pt.month))),
          DataCell(Text(pt.orders.toString())),
          DataCell(Text(NumberFormat.simpleCurrency(decimalDigits: 2).format(pt.revenue))),
        ]);
      }).toList(),
    );
  }

  // ---------- Static helpers ----------
  static List<_ChartPoint> _mergeMonthlyData(
      List<MonthlyCount> orders,
      List<MonthlyRevenue> revenue,
      ) {
    // union preserving order of appearance
    final months = <String>[];
    for (final o in orders) {
      if (!months.contains(o.month)) months.add(o.month);
    }
    for (final r in revenue) {
      if (!months.contains(r.month)) months.add(r.month);
    }

    // parse months to DateTime and build maps
    DateTime? parseMonth(String m) {
      // Accept "yyyy-MM" and "yyyy-MM-dd"
      try {
        if (m.length == 7) return DateFormat('yyyy-MM').parseLoose(m);
        return DateFormat('yyyy-MM-dd').parseLoose(m);
      } catch (_) {
        // last fallback: try full parse
        try {
          return DateTime.parse(m);
        } catch (_) {
          return null;
        }
      }
    }

    final orderMap = {for (var o in orders) o.month: o.count};
    final revenueMap = {for (var r in revenue) r.month: r.revenue};

    final points = <_ChartPoint>[];
    for (final m in months) {
      final dt = parseMonth(m) ?? DateTime.now();
      final o = orderMap[m] ?? 0;
      final rev = (revenueMap[m] ?? 0).toDouble();
      points.add(_ChartPoint(month: dt, orders: o, revenue: rev));
    }
    return points;
  }
}

/// Small immutable model used by the chart
class _ChartPoint {
  final DateTime month;
  final int orders;
  final double revenue;

  const _ChartPoint({
    required this.month,
    required this.orders,
    required this.revenue,
  });
}
