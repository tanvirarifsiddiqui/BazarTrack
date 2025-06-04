import 'order_status.dart';

class Order {
  final String orderId;
  final String createdBy;
  String? assignedTo;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  Order({
    required this.orderId,
    required this.createdBy,
    this.assignedTo,
    this.status = OrderStatus.draft,
    required this.createdAt,
    this.completedAt,
  });

  Order.fromJson(Map<String, dynamic> json)
      : orderId = json['orderId'],
        createdBy = json['createdBy'],
        assignedTo = json['assignedTo'],
        status = OrderStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => OrderStatus.draft,
        ),
        createdAt = DateTime.parse(json['createdAt']),
        completedAt = json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'createdBy': createdBy,
        'assignedTo': assignedTo,
        'status': status.toString(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}
