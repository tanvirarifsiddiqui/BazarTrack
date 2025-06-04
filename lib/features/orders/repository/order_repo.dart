import 'package:flutter_boilerplate/data/model/order/order.dart';
import 'package:flutter_boilerplate/data/model/order/order_status.dart';

class OrderRepo {
  final List<Order> _orders = [];

  List<Order> getOrders({OrderStatus? status, String? assignedTo}) {
    return _orders.where((o) {
      if (status != null && o.status != status) return false;
      if (assignedTo != null && o.assignedTo != assignedTo) return false;
      return true;
    }).toList();
  }

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.orderId == id);
    } catch (_) {
      return null;
    }
  }

  void createOrder(Order order) {
    _orders.add(order);
  }

  void updateOrder(Order order) {
    final index = _orders.indexWhere((o) => o.orderId == order.orderId);
    if (index != -1) {
      _orders[index] = order;
    }
  }

  void assignOrder(String orderId, String userId) {
    final order = getById(orderId);
    if (order != null) {
      order.assignedTo = userId;
      order.status = OrderStatus.assigned;
    }
  }

  bool selfAssign(String orderId, String userId) {
    final order = getById(orderId);
    if (order != null && order.assignedTo == null) {
      order.assignedTo = userId;
      order.status = OrderStatus.assigned;
      return true;
    }
    return false;
  }
}
