// lib/features/dashboard/components/reports_chart_syncfusion.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../model/assistant_analytics.dart';
import '../model/monthly_report.dart';

class ReportsChartSyncfusion extends StatelessWidget {
  final List<_ChartPoint> _data; // sparse points (only months returned by API)
  final ThemeData theme;
  final bool showTableBelow;
  final Widget? customBelow;

  const ReportsChartSyncfusion._({
    Key? key,
    required List<_ChartPoint> data,
    required this.theme,
    this.showTableBelow = true,
    this.customBelow,
  })  : _data = data,
        super(key: key);

  factory ReportsChartSyncfusion.fromAssistantAnalytics(
      AssistantAnalytics analytics, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final points = _mergeMonthlyData(analytics.ordersByMonth, analytics.revenueByMonth);
    return ReportsChartSyncfusion._(
      data: points,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  factory ReportsChartSyncfusion.fromReportsData(
      ReportsData reports, ThemeData theme,
      {bool showTableBelow = true, Widget? customBelow}) {
    final points = _mergeMonthlyData(reports.ordersByMonth, reports.revenueByMonth);
    return ReportsChartSyncfusion._(
      data: points,
      theme: theme,
      showTableBelow: showTableBelow,
      customBelow: customBelow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabelFmt = DateFormat('MMM yyyy'); // "Aug 2025"
    final currencyFmt = NumberFormat.simpleCurrency(decimalDigits: 0);

    if (_data.isEmpty) {
      return Center(child: Text('No data available', style: theme.textTheme.bodyMedium));
    }

    // Only months present in API — ensure chronological order
    final points = List<_ChartPoint>.from(_data)..sort((a, b) => a.month.compareTo(b.month));

    // Totals for the small visualization above the chart
    final totalOrders = points.fold<int>(0, (sum, p) => sum + p.orders);
    final totalRevenue = points.fold<double>(0.0, (sum, p) => sum + p.revenue);

    // Axis maxima (20% headroom) but with sensible minimums
    final maxOrders = points.map((p) => p.orders).fold<int>(0, (a, b) => a > b ? a : b);
    final maxRevenue = points.map((p) => p.revenue).fold<double>(0.0, (a, b) => a > b ? a : b);
    final orderTop = ((maxOrders == 0) ? 5.0 : (maxOrders * 1.2)).clamp(5.0, double.infinity);
    final revenueTop = ((maxRevenue == 0.0) ? 5.0 : (maxRevenue * 1.2)).clamp(5.0, double.infinity);

    // X axis bounds: use exact first and last months from data to avoid extra ticks
    DateTime minX = DateTime(points.first.month.year, points.first.month.month, 1);
    DateTime maxX = DateTime(points.last.month.year, points.last.month.month, 1);

    // If only one month present, extend maxX by one month so axis renders nicely
    if (minX.isAtSameMomentAs(maxX)) {
      maxX = DateTime(maxX.year + (maxX.month == 12 ? 1 : 0), (maxX.month % 12) + 1, 1);
    }

    // Label interval logic to prevent crowding
    final visibleLabelCount = 6;
    final interval = (points.length <= visibleLabelCount) ? 1 : (points.length / visibleLabelCount).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Chart card ---
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 340,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                legend: Legend(isVisible: true, position: LegendPosition.top, overflowMode: LegendItemOverflowMode.wrap),
                tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),

                primaryXAxis: DateTimeAxis(
                  dateFormat: monthLabelFmt,
                  intervalType: DateTimeIntervalType.months,
                  interval: interval.toDouble(),
                  labelRotation: (points.length > 8) ? -30 : 0,
                  minimum: minX,     // <-- important: explicitly set minimum
                  maximum: maxX,     // <-- important: explicitly set maximum
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  majorGridLines: const MajorGridLines(width: 0.0),
                ),

                primaryYAxis: NumericAxis(
                  name: 'ordersAxis',
                  title: AxisTitle(text: 'Orders'),
                  minimum: 0,
                  maximum: orderTop,
                  interval: (orderTop / 4).ceilToDouble(),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),

                axes: <ChartAxis>[
                  NumericAxis(
                    name: 'revenueAxis',
                    title: AxisTitle(text: 'Revenue'),
                    minimum: 0,
                    maximum: revenueTop,
                    interval: (revenueTop / 4),
                    opposedPosition: true,
                    numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                    majorGridLines: const MajorGridLines(width: 0.0),
                  ),
                ],

                series: <CartesianSeries<_ChartPoint, DateTime>>[
                  ColumnSeries<_ChartPoint, DateTime>(
                    dataSource: points,
                    xValueMapper: (pt, _) => pt.month,
                    yValueMapper: (pt, _) => pt.orders,
                    name: 'Orders',
                    width: 0.6,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: theme.colorScheme.primary,
                    enableTooltip: true,
                    animationDuration: 700,
                  ),
                  LineSeries<_ChartPoint, DateTime>(
                    dataSource: points,
                    xValueMapper: (pt, _) => pt.month,
                    yValueMapper: (pt, _) => pt.revenue,
                    yAxisName: 'revenueAxis',
                    name: 'Revenue',
                    width: 2.5,
                    color: theme.colorScheme.secondary,
                    markerSettings: MarkerSettings(isVisible: true, borderWidth: 1.5),
                    enableTooltip: true,
                    animationDuration: 900,
                  ),
                ],

                zoomPanBehavior: ZoomPanBehavior(enablePanning: true, enablePinching: true),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (customBelow != null) ...[
          customBelow!,
        ] else if (showTableBelow) ...[
          _buildCombinedTable(points, monthLabelFmt, currencyFmt),
        ],
      ],
    );
  }

  Widget _buildCombinedTable(List<_ChartPoint> pts, DateFormat monthLabelFmt, NumberFormat currencyFmt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: DataTable(
        columnSpacing: 12,
        columns: const [
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Revenue')),
        ],
        rows: pts.map((pt) {
          return DataRow(cells: [
            DataCell(Text(monthLabelFmt.format(pt.month))),
            DataCell(Text(pt.orders.toString())),
            DataCell(Text(currencyFmt.format(pt.revenue))),
          ]);
        }).toList(),
      ),
    );
  }

  static List<_ChartPoint> _mergeMonthlyData(List<MonthlyCount> orders, List<MonthlyRevenue> revenue) {
    final DateFormat keyFmt = DateFormat('yyyy-MM');

    final orderMap = <String, int>{
      for (var o in orders) keyFmt.format(_parseMonthToFirstOfMonth(o.month)): o.count
    };
    final revenueMap = <String, double>{
      for (var r in revenue) keyFmt.format(_parseMonthToFirstOfMonth(r.month)): r.revenue
    };

    final seen = <String>[];
    for (final o in orders) {
      final k = keyFmt.format(_parseMonthToFirstOfMonth(o.month));
      if (!seen.contains(k)) seen.add(k);
    }
    for (final r in revenue) {
      final k = keyFmt.format(_parseMonthToFirstOfMonth(r.month));
      if (!seen.contains(k)) seen.add(k);
    }

    if (seen.isEmpty) {
      seen.addAll(orderMap.keys);
      seen.addAll(revenueMap.keys);
    }

    final months = seen.map((k) {
      final parts = k.split('-');
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? DateTime.now().month;
      return DateTime(y, m, 1);
    }).toList()
      ..sort((a, b) => a.compareTo(b));

    final points = months.map((dt) {
      final k = keyFmt.format(dt);
      return _ChartPoint(month: dt, orders: orderMap[k] ?? 0, revenue: revenueMap[k] ?? 0.0);
    }).toList(growable: false);

    return points;
  }

  static DateTime _parseMonthToFirstOfMonth(String m) {
    try {
      if (m.length == 7) return DateFormat('yyyy-MM').parseLoose(m);
      return DateFormat('yyyy-MM-dd').parseLoose(m);
    } catch (_) {
      try {
        return DateTime.parse(m);
      } catch (_) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      }
    }
  }
}

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
