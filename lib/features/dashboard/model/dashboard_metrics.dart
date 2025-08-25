class DashboardMetrics {
  final int totalUsers;
  final int totalOrders;
  final int totalPayments;
  final double totalExpense;

  DashboardMetrics({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalPayments,
    required this.totalExpense,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers:    json['total_users']    as int,
      totalOrders:   json['total_orders']   as int,
      totalPayments: json['total_payments'] as int,
      totalExpense:  (json['total_expense'] as num).toDouble(),
    );
  }
}
