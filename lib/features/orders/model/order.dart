// File: lib/features/orders/model/order.dart

import 'order_item.dart';
import 'order_status.dart';
import '../../../helper/date_converter.dart';

/// Represents an Order with optional `id` for new orders.
class Order {
  final String? orderId;       // Nullable: server-assigned on creation
  final String createdBy;
  String? assignedTo;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  /// Constructor for existing (fetched) orders
  Order({
    required this.orderId,
    required this.createdBy,
    this.assignedTo,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  /// Constructor for creating new orders (no `orderId` yet)
  factory Order.create({
    required String createdBy,
    String? assignedTo,
    OrderStatus status = OrderStatus.pending,
    required DateTime createdAt,
    DateTime? completedAt,
  }) => Order(
    orderId: null,
    createdBy: createdBy,
    assignedTo: assignedTo,
    status: status,
    createdAt: createdAt,
    completedAt: completedAt,
  );

  /// Deserialize from API JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: (json['id'] ?? json['orderId']).toString(),
      createdBy: (json['created_by'] ?? json['createdBy']).toString(),
      assignedTo: json['assigned_to']?.toString() ?? json['assignedTo']?.toString(),
      status: OrderStatusExtension.fromString(json['status'] ?? 'pending'),
      createdAt: DateConverter.parseApiDate(
          json['created_at'] ?? json['createdAt']),
      completedAt: json['completed_at'] != null
          ? DateConverter.parseApiDate(json['completed_at'])
          : (json['completedAt'] != null
          ? DateConverter.parseApiDate(json['completedAt'])
          : null),
    );
  }

  /// Convenience parsed integer id for internal use (nullable)
  int? get id {
    if (orderId == null) return null;
    return int.tryParse(orderId!);
  }


  /// Full JSON for updates/fetch
  Map<String, dynamic> toJson() => {
    if (orderId != null) 'id': orderId,
    'created_by': createdBy,
    'assigned_to': assignedTo,
    'status': status.toApi(),
    'created_at': DateConverter.formatApiDate(createdAt),
    'completed_at': completedAt != null
        ? DateConverter.formatApiDate(completedAt!) : null,
  };

  /// JSON for creating a new order with nested items
  Map<String, dynamic> toJsonForCreate({
    required List<OrderItem> items,
  }) {
    final Map<String, dynamic> map = {
      'created_by': int.tryParse(createdBy) ?? createdBy,
      'status': status.toApi(),
      'created_at': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJsonForCreate()).toList(),
    };

    // only include assigned_to if it's provided (and convert to int if possible)
    if (assignedTo != null && assignedTo!.isNotEmpty) {
      final parsed = int.tryParse(assignedTo!);
      map['assigned_to'] = parsed ?? assignedTo;
    }

    // include completed_at only if present (omit otherwise)
    if (completedAt != null) {
      map['completed_at'] = completedAt!.toIso8601String();
    }

    return map;
  }
}