import 'monthly_report.dart';

class AssistantAnalytics {
  final int totalOrders;
  final double totalExpense;
  final List<MonthlyCount>   ordersByMonth;
  final List<MonthlyResponse> expenseByMonth;

  AssistantAnalytics({
    required this.totalOrders,
    required this.totalExpense,
    required this.ordersByMonth,
    required this.expenseByMonth,
  });

  factory AssistantAnalytics.fromJson(Map<String, dynamic> json) {
    return AssistantAnalytics(
      totalOrders:    json['total_orders']   as int,
      totalExpense:   (json['total_expense'] as num).toDouble(),
      ordersByMonth:  (json['orders_by_month'] as List)
          .map((e) => MonthlyCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseByMonth: (json['expense_by_month'] as List)
          .map((e) => MonthlyResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
