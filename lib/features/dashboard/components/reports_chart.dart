// lib/features/dashboard/components/reports_chart_syncfusion.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../model/assistant_analytics.dart';
import '../model/monthly_report.dart';


class ReportsChartSyncfusion extends StatelessWidget {
  final List<_ChartPoint> _data; // raw points (may be sparse)
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

  /// Build from AssistantAnalytics
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

  /// Build from ReportsData (owner)
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
    final monthLabelFmt = DateFormat('MMM'); // -> "Aug"
    final yearFmt = DateFormat('yyyy');

    if (_data.isEmpty) {
      return Center(child: Text('No data available', style: theme.textTheme.bodyMedium));
    }

    // 1) Build a *full* chronological month sequence from min -> max
    final sorted = List<_ChartPoint>.from(_data)..sort((a, b) => a.month.compareTo(b.month));
    final start = DateTime(sorted.first.month.year, sorted.first.month.month, 1);
    final end = DateTime(sorted.last.month.year, sorted.last.month.month, 1);

    final fullMonths = <DateTime>[];
    DateTime cur = start;
    while (!cur.isAfter(end)) {
      fullMonths.add(cur);
      // increment month safely
      cur = DateTime(cur.year + (cur.month == 12 ? 1 : 0), (cur.month % 12) + 1, 1);
    }

    // 2) Build lookup maps keyed by 'yyyy-MM' so we can fill missing months with zeros
    final DateFormat keyFmt = DateFormat('yyyy-MM');
    final orderMap = <String, int>{};
    final revenueMap = <String, double>{};
    for (final p in _data) {
      final k = keyFmt.format(DateTime(p.month.year, p.month.month, 1));
      orderMap[k] = p.orders;
      revenueMap[k] = p.revenue;
    }

    // 3) Create final points sequence (one point per month)
    final points = fullMonths.map((dt) {
      final key = keyFmt.format(dt);
      return _ChartPoint(
        month: dt,
        orders: orderMap[key] ?? 0,
        revenue: (revenueMap[key] ?? 0.0),
      );
    }).toList(growable: false);

    // Axis ranges
    final maxOrders = points.map((e) => e.orders).fold<int>(0, (a, b) => a > b ? a : b);
    final maxRevenue = points.map((e) => e.revenue).fold<double>(0.0, (a, b) => a > b ? a : b);
    final orderTop = (maxOrders * 1.2).clamp(5.0, double.infinity);
    final revenueTop = (maxRevenue * 1.2).clamp(5.0, double.infinity);

    // Year range string e.g. "2024 — 2025" or single year "2025"
    final yearRangeText = (start.year == end.year) ? '${start.year}' : '${start.year} — ${end.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 330,
          child: SfCartesianChart(
            legend: Legend(isVisible: true, position: LegendPosition.top),
            tooltipBehavior: TooltipBehavior(enable: true, header: ''),
            // X axis shows month abbreviations (MMM)
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.months,
              dateFormat: monthLabelFmt, // "Aug"
              interval: 1, // force every month label
              minimum: fullMonths.first,
              maximum: fullMonths.last,
              majorGridLines: const MajorGridLines(width: 0.5),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelRotation: -45, // rotate to avoid overlap on small screens
              // if many months appear, you can also use labelIntersectAction to hide some
              // labelIntersectAction: AxisLabelIntersectAction.hide,
            ),
            // Left Y: Orders (integers)
            primaryYAxis: NumericAxis(
              name: 'ordersAxis',
              title: AxisTitle(text: 'Orders'),
              minimum: 0,
              maximum: orderTop,
              interval: (orderTop / 4).ceilToDouble(),
              opposedPosition: false,
              numberFormat: NumberFormat.decimalPattern(), // integer-like labels
              labelStyle: TextStyle(fontSize: 12),
            ),
            // Right Y: Revenue (currency, no decimals)
            axes: <ChartAxis>[
              NumericAxis(
                name: 'revenueAxis',
                title: AxisTitle(text: 'Revenue'),
                minimum: 0,
                maximum: revenueTop,
                interval: (revenueTop / 4),
                opposedPosition: true,
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                labelStyle: TextStyle(fontSize: 12),
                // reduce padding by setting width/label properties if needed
              ),
            ],

            // Use strongly-typed series list
            series: <CartesianSeries<_ChartPoint, DateTime>>[
              ColumnSeries<_ChartPoint, DateTime>(
                dataSource: points,
                xValueMapper: (pt, _) => pt.month,
                yValueMapper: (pt, _) => pt.orders,
                name: 'Orders',
                width: 0.6,
                color: theme.colorScheme.primary,
                enableTooltip: true,
              ),
              LineSeries<_ChartPoint, DateTime>(
                dataSource: points,
                xValueMapper: (pt, _) => pt.month,
                yValueMapper: (pt, _) => pt.revenue,
                yAxisName: 'revenueAxis',
                name: 'Revenue',
                markerSettings: MarkerSettings(isVisible: true),
                width: 2,
                color: theme.colorScheme.secondary,
                enableTooltip: true,
              ),
            ],

            zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true),
          ),
        ),

        // show computed year range centered under chart
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 6),
          child: Center(
            child: Text(
              yearRangeText,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // structured table below (optional)
        if (customBelow != null) ...[
          customBelow!,
        ] else if (showTableBelow) ...[
          _buildCombinedTable(points),
        ],
      ],
    );
  }

  Widget _buildCombinedTable(List<_ChartPoint> points) {
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Orders')),
        DataColumn(label: Text('Revenue')),
      ],
      rows: points.map((pt) {
        return DataRow(cells: [
          DataCell(Text(DateFormat('MMM').format(pt.month))),
          DataCell(Text(pt.orders.toString())),
          DataCell(Text(currency.format(pt.revenue))),
        ]);
      }).toList(),
    );
  }

  // merges original (sparse) lists into _ChartPoint list
  static List<_ChartPoint> _mergeMonthlyData(
      List<MonthlyCount> orders, List<MonthlyRevenue> revenue) {
    // Build maps keyed by 'yyyy-MM'
    final DateFormat keyFmt = DateFormat('yyyy-MM');
    final orderMap = <String, int>{for (var o in orders) keyFmt.format(_parseMonthToFirstOfMonth(o.month)) : o.count};
    final revenueMap = <String, double>{for (var r in revenue) keyFmt.format(_parseMonthToFirstOfMonth(r.month)) : r.revenue};

    // Collect union months in original order (if you prefer strict chronological only, sort later)
    final seen = <String>[];
    for (final o in orders) {
      final k = keyFmt.format(_parseMonthToFirstOfMonth(o.month));
      if (!seen.contains(k)) seen.add(k);
    }
    for (final r in revenue) {
      final k = keyFmt.format(_parseMonthToFirstOfMonth(r.month));
      if (!seen.contains(k)) seen.add(k);
    }

    // If for some reason union is empty, fallback to maps' keys
    if (seen.isEmpty) {
      seen.addAll(orderMap.keys);
      seen.addAll(revenueMap.keys);
    }

    // Parse to DateTimes and sort to ensure chronological order
    final months = seen.map((k) {
      final parts = k.split('-');
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? DateTime.now().month;
      return DateTime(y, m, 1);
    }).toList()
      ..sort((a, b) => a.compareTo(b));

    // Build points (note: we do not fill the holes here; fill is done in build() to get full range)
    final points = months.map((dt) {
      final k = keyFmt.format(dt);
      return _ChartPoint(month: dt, orders: orderMap[k] ?? 0, revenue: revenueMap[k] ?? 0.0);
    }).toList();

    return points;
  }

  // helper parse for 'yyyy-MM' or 'yyyy-MM-dd' or fallback
  static DateTime _parseMonthToFirstOfMonth(String m) {
    try {
      if (m.length == 7) return DateFormat('yyyy-MM').parseLoose(m);
      return DateFormat('yyyy-MM-dd').parseLoose(m);
    } catch (_) {
      try {
        return DateTime.parse(m);
      } catch (_) {
        return DateTime.now();
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
