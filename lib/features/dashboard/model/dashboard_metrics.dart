class DashboardMetrics {
  final int totalUsers;
  final int totalOrders;
  final int totalPayments;
  final double totalRevenue;

  DashboardMetrics({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalPayments,
    required this.totalRevenue,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers:    json['total_users']    as int,
      totalOrders:   json['total_orders']   as int,
      totalPayments: json['total_payments'] as int,
      totalRevenue:  (json['total_revenue'] as num).toDouble(),
    );
  }
}
