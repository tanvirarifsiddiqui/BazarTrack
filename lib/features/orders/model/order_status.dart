// File: lib/features/orders/model/order_status.dart

enum OrderStatus { pending, assigned, completed }

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'assigned':
        return OrderStatus.assigned;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }

  String toApi() {
    switch (this) {
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.completed:
        return 'completed';
      default:
        return 'pending';
    }
  }
}