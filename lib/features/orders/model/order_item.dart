// File: lib/features/orders/model/order_item.dart

enum OrderItemStatus { pending, purchased, unavailable }

extension OrderItemStatusX on OrderItemStatus {
  String toApi() {
    switch (this) {
      case OrderItemStatus.purchased:
        return 'purchased';
      case OrderItemStatus.unavailable:
        return 'unavailable';
      default:
        return 'pending';
    }
  }

  static OrderItemStatus fromApi(String value) {
    final v = value.toLowerCase();
    if (v == 'purchased') return OrderItemStatus.purchased;
    if (v == 'unavailable') return OrderItemStatus.unavailable;
    return OrderItemStatus.pending;
  }
}

class OrderItem {
  final int? id;
  final int orderId;
  final String productName;
  final int quantity;
  final String unit;
  final double? estimatedCost;
  final double? actualCost;
  final OrderItemStatus status;

  const OrderItem({
    this.id,
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.estimatedCost,
    this.actualCost,
    this.status = OrderItemStatus.pending,
  });

  factory OrderItem.empty({required int orderId}) {
    return OrderItem(
      orderId: orderId,
      productName: '',
      quantity: 1,
      unit: 'pcs',
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return OrderItem(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id'])!,
      productName: json['product_name']?.toString() ?? '',
      quantity: parseInt(json['quantity']) ?? 0,
      unit: json['unit'] as String? ?? '',
      estimatedCost: json['estimated_cost'] != null
          ? double.tryParse(json['estimated_cost'].toString())
          : null,
      actualCost: json['actual_cost'] != null
          ? double.tryParse(json['actual_cost'].toString())
          : null,
      status: json['status'] != null
          ? OrderItemStatusX.fromApi(json['status'] as String)
          : OrderItemStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'order_id': orderId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'status': status.toApi(),
    };
    if (id != null) data['id'] = id;
    if (estimatedCost != null) data['estimated_cost'] = estimatedCost;
    if (actualCost != null) data['actual_cost'] = actualCost;
    return data;
  }

  Map<String, dynamic> toJsonForCreate() {
    final data = <String, dynamic>{
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      'status': status.toApi(),
    };
    if (estimatedCost != null) data['estimated_cost'] = estimatedCost;
    if (actualCost != null) data['actual_cost'] = actualCost;
    return data;
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    String? productName,
    int? quantity,
    String? unit,
    double? estimatedCost,
    double? actualCost,
    OrderItemStatus? status,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      status: status ?? this.status,
    );
  }
}