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

class MonthlyResponse {
  final String month;
  final double expense;

  MonthlyResponse({ required this.month, required this.expense });

  factory MonthlyResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyResponse(
      month:   json['month'] as String,
      expense: double.parse(json['expense'].toString()),
    );
  }
}

class ReportsData {
  final List<MonthlyCount>   ordersByMonth;
  final List<MonthlyResponse> expenseByMonth;

  ReportsData({
    required this.ordersByMonth,
    required this.expenseByMonth,
  });

  factory ReportsData.fromJson(Map<String, dynamic> json) {
    return ReportsData(
      ordersByMonth: (json['orders_by_month'] as List)
          .map((e) => MonthlyCount.fromJson(e))
          .toList(),
      expenseByMonth: (json['expense_by_month'] as List)
          .map((e) => MonthlyResponse.fromJson(e))
          .toList(),
    );
  }
}
