enum OrderStatus { pending, inProgress, completed }

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }

  String toApi() {
    switch (this) {
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.completed:
        return 'completed';
      default:
        return 'pending';
    }
  }
}
