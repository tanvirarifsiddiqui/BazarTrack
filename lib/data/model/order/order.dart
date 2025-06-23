import 'order_status.dart';
import '../../../helper/date_converter.dart';

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
        createdAt = DateConverter.parseApiDate(
            json['createdAt'] ?? json['created_at']),
        completedAt = json['completedAt'] != null
            ? DateConverter.parseApiDate(json['completedAt'])
            : json['completed_at'] != null
                ? DateConverter.parseApiDate(json['completed_at'])
                : null;

  Map<String, dynamic> toJson() => {
        'id': orderId,
        'created_by': createdBy,
        'assigned_to': assignedTo,
        'status': status.toApi(),
        'created_at': DateConverter.formatApiDate(createdAt),
        'completed_at': completedAt != null
            ? DateConverter.formatApiDate(completedAt!)
            : null,
      };
}
