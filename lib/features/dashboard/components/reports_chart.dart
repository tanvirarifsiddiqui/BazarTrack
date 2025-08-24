// lib/features/dashboard/components/reports_chart_syncfusion.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../util/dimensions.dart';
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
    // Month label uses only the month abbreviation (Jan, Feb, Mar)
    final monthOnlyFmt = DateFormat('MMM');
    final monthAndYearFmt = DateFormat('MMM yyyy');
    final currencyFmt = NumberFormat.simpleCurrency(decimalDigits: 0,name:"৳");

    if (_data.isEmpty) {
      return Center(child: Text('No data available', style: theme.textTheme.bodyMedium));
    }

    final points = List<_ChartPoint>.from(_data)..sort((a, b) => a.month.compareTo(b.month));

    // Build simple month labels (MMM) for each data point (keeps one label per point)
    final labels = points.map((p) => monthOnlyFmt.format(p.month)).toList(growable: false);

    // Compute year range text (single line), e.g. "2025" or "2024 — 2025"
    final int startYear = points.first.month.year;
    final int endYear = points.last.month.year;
    final String yearRangeText = (startYear == endYear) ? '$startYear' : '$startYear — $endYear';

    // axis maxima (20% headroom)
    final maxOrders = points.map((p) => p.orders).fold<int>(0, (a, b) => a > b ? a : b);
    final maxRevenue = points.map((p) => p.revenue).fold<double>(0.0, (a, b) => a > b ? a : b);
    final orderTop = ((maxOrders == 0) ? 5.0 : (maxOrders * 1.2)).clamp(5.0, double.infinity);
    final revenueTop = ((maxRevenue == 0.0) ? 5.0 : (maxRevenue * 1.2)).clamp(5.0, double.infinity);

    // Label interval logic: show at most ~6 labels to avoid crowding
    final visibleLabelCount = 6;
    final labelInterval = (labels.length <= visibleLabelCount) ? 1 : (labels.length / visibleLabelCount).ceil();


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  SfCartesianChart(
                    margin: const EdgeInsets.all(8),
                    plotAreaBorderWidth: 0,
                    plotAreaBackgroundColor: Colors.blue.shade50,
                    legend: Legend(isVisible: true, position: LegendPosition.top, overflowMode: LegendItemOverflowMode.wrap),
                    tooltipBehavior: TooltipBehavior(enable: true),

                    // CategoryAxis: exact categories for each point; label shows only month (MMM)
                    primaryXAxis: CategoryAxis(
                      labelRotation: (labels.length > 8) ? -30 : 0,
                      interval: labelInterval.toDouble(),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),

                    // Left Y: Orders
                    primaryYAxis: NumericAxis(
                      name: 'ordersAxis',
                      title: AxisTitle(text: 'Orders'),
                      minimum: 0,
                      maximum: orderTop,
                      interval: (orderTop / 4).ceilToDouble(),
                      majorGridLines: const MajorGridLines(width: 0.5),
                    ),

                    // Right Y: Revenue
                    axes: <ChartAxis>[
                      NumericAxis(
                        name: 'revenueAxis',
                        title: AxisTitle(text: 'Revenue'),
                        minimum: 0,
                        maximum: revenueTop,
                        interval: (revenueTop / 4),
                        opposedPosition: true,
                        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, name:"৳"),
                        majorGridLines: const MajorGridLines(width: 0.0),
                      ),
                    ],

                    // Series using category (String) X values (month abbreviations)
                    series: <CartesianSeries<_ChartPoint, String>>[
                      ColumnSeries<_ChartPoint, String>(
                        dataSource: points,
                        xValueMapper: (pt, _) => monthOnlyFmt.format(pt.month),
                        yValueMapper: (pt, _) => pt.orders,
                        name: 'Orders',
                        width: 0.6,
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        color: theme.colorScheme.primary,
                        enableTooltip: true,
                        animationDuration: 600,
                      ),
                      LineSeries<_ChartPoint, String>(
                        dataSource: points,
                        xValueMapper: (pt, _) => monthOnlyFmt.format(pt.month),
                        yValueMapper: (pt, _) => pt.revenue,
                        yAxisName: 'revenueAxis',
                        name: 'Revenue',
                        width: 2.2,
                        color: theme.colorScheme.secondary,
                        markerSettings: MarkerSettings(isVisible: true),
                        enableTooltip: true,
                        animationDuration: 750,
                      ),
                    ],

                    zoomPanBehavior: ZoomPanBehavior(enablePanning: true, enablePinching: true),
                  ),
                  // Centered year range below the chart (single line)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 8.0),
                    child: Center(
                      child: Text(
                        yearRangeText,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


        const SizedBox(height: 16),

        if (customBelow != null) ...[
          customBelow!,
        ] else if (showTableBelow) ...[
          _buildCombinedTable(points, monthAndYearFmt, currencyFmt),
        ],
      ],
    );
  }

  Widget _buildCombinedTable(List<_ChartPoint> pts, DateFormat monthLabelFmt, NumberFormat currencyFmt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius)),
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
