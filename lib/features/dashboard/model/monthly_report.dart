class MonthlyCount {
  final String month; // e.g. "2025-08"
  final int    count;

  MonthlyCount({ required this.month, required this.count });

  factory MonthlyCount.fromJson(Map<String, dynamic> json) {
    return MonthlyCount(
      month: json['month'] as String,
      count: json['count'] as int,
    );
  }
}

class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({ required this.month, required this.revenue });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month:   json['month'] as String,
      revenue: double.parse(json['revenue'].toString()),
    );
  }
}

class ReportsData {
  final List<MonthlyCount>   ordersByMonth;
  final List<MonthlyRevenue> revenueByMonth;

  ReportsData({
    required this.ordersByMonth,
    required this.revenueByMonth,
  });

  factory ReportsData.fromJson(Map<String, dynamic> json) {
    return ReportsData(
      ordersByMonth: (json['orders_by_month'] as List)
          .map((e) => MonthlyCount.fromJson(e))
          .toList(),
      revenueByMonth: (json['revenue_by_month'] as List)
          .map((e) => MonthlyRevenue.fromJson(e))
          .toList(),
    );
  }
}
