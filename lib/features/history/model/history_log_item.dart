// lib/features/history/model/history_log_item.dart

class HistoryLogItem {
  final String   productName;
  final int      quantity;
  final String   unit;
  final String   status;
  final double?  estimatedCost;
  final double?  actualCost;

  HistoryLogItem({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.estimatedCost,
    this.actualCost,
  });

  factory HistoryLogItem.fromJson(Map<String, dynamic> json) {
    // parse int and double robustly
    int parseInt(dynamic v) {
      if (v is int)    return v;
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is double) return v.toInt();
      return 0;
    }

    double? parseDouble(dynamic v) {
      if (v == null)   return null;
      if (v is num)    return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return HistoryLogItem(
      productName:   json['product_name'] as String? ?? '',
      quantity:      parseInt(json['quantity']),
      unit:          json['unit'] as String? ?? '',
      status:        json['status'] as String? ?? '',
      estimatedCost: parseDouble(json['estimated_cost']),
      actualCost:    parseDouble(json['actual_cost']),
    );
  }
}
