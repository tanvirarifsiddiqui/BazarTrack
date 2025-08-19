import 'monthly_report.dart';

class AssistantAnalytics {
  final int totalOrders;
  final double totalRevenue;
  final List<MonthlyCount>   ordersByMonth;
  final List<MonthlyRevenue> revenueByMonth;

  AssistantAnalytics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.ordersByMonth,
    required this.revenueByMonth,
  });

  factory AssistantAnalytics.fromJson(Map<String, dynamic> json) {
    return AssistantAnalytics(
      totalOrders:    json['total_orders']   as int,
      totalRevenue:   (json['total_revenue'] as num).toDouble(),
      ordersByMonth:  (json['orders_by_month'] as List)
          .map((e) => MonthlyCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      revenueByMonth: (json['revenue_by_month'] as List)
          .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
