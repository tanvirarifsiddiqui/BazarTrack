import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import 'package:flutter_boilerplate/data/model/order/order.dart';
import 'package:flutter_boilerplate/data/model/order/order_status.dart';

class OrderRepo {
  final BazarTrackApi api;
  OrderRepo({required this.api});

  final List<Order> _cache = [];

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) async {
    final res = await api.orders();
    if (res.isOk && res.body is List) {
      _cache
        ..clear()
        ..addAll((res.body as List).map((e) => Order.fromJson(e)));
    }
    return _cache.where((o) {
      if (status != null && o.status != status) return false;
      if (assignedTo != null && o.assignedTo != assignedTo) return false;
      return true;
    }).toList();
  }

  Order? getById(String id) {
    try {
      return _cache.firstWhere((o) => o.orderId == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createOrder(Order order) async {
    await api.createOrder(order.toJson());
    _cache.add(order);
  }

  Future<void> updateOrder(Order order) async {
    await api.updateOrder(int.parse(order.orderId), order.toJson());
    final index = _cache.indexWhere((o) => o.orderId == order.orderId);
    if (index != -1) {
      _cache[index] = order;
    }
  }

  Future<void> assignOrder(String orderId, String userId) async {
    await api.assignOrder(int.parse(orderId), {'user_id': int.parse(userId)});
    final order = getById(orderId);
    if (order != null) {
      order.assignedTo = userId;
      order.status = OrderStatus.assigned;
    }
  }

  bool selfAssign(String orderId, String userId) {
    assignOrder(orderId, userId);
    return true;
  }
}
