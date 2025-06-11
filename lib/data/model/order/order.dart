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
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  Order.fromJson(Map<String, dynamic> json)
      : orderId = (json['orderId'] ?? json['id']).toString(),
        createdBy = (json['createdBy'] ?? json['created_by']).toString(),
        assignedTo = json['assignedTo']?.toString() ??
            json['assigned_to']?.toString(),
        status = OrderStatusExtension.fromString(json['status'] ?? 'pending'),
        createdAt = DateTime.parse(
            json['createdAt'] ?? json['created_at']),
        completedAt = json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : json['completed_at'] != null
                ? DateTime.parse(json['completed_at'])
                : null;

  Map<String, dynamic> toJson() => {
        'id': orderId,
        'created_by': createdBy,
        'assigned_to': assignedTo,
        'status': status.toApi(),
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };
}
