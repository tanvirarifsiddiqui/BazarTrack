// File: lib/features/orders/repository/order_repo.dart

import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:get/get.dart';
import '../model/order_item.dart';

class OrderRepo {
  final BazarTrackApi api;
  OrderRepo({required this.api});

  final List<Order> _cache = [];
  final List<OrderItem> _itemCache = [];


  Future<OrderItem> updateOrderItem(OrderItem item) async {
    final res = await api.updateItem(
      item.orderId,
      item.id!,
      item.toJson(),
    );

    if (!res.isOk || res.body is! Map<String, dynamic>) {
      throw Exception('Failed to update order item (${res.statusCode})');
    }

    final body = Map<String, dynamic>.from(res.body as Map);
    // Some APIs return order_id:null on update—fix it here
    body['order_id'] ??= item.orderId;

    final updated = OrderItem.fromJson(body);

    // update your local cache if you have one
    return updated;
  }
  Future<void> deleteOrderItem(int orderId, int id) async {
    final res = await api.deleteItem(orderId, id);
    if (!res.isOk) {
      throw Exception('Failed to delete order item (${res.statusCode})');
    }
  }

  Future<void> completeOrder(String orderId) async {
    await api.completeOrder(int.parse(orderId), {});
  }


  /// Create order + nested items in one HTTP call (if server supports nesting)
  Future<Order> createOrderWithItems(Order order, List<OrderItem> items) async {
    final payload = order.toJsonForCreate(items: items);
    final res = await api.createOrder(payload);
    if (!res.isOk || res.body is! Map<String, dynamic>) {
      throw Exception('Failed to create order with items: ${res.statusCode}');
    }
    final createdOrder = Order.fromJson(res.body as Map<String, dynamic>);
    _cache.add(createdOrder);
    return createdOrder;
  }

  /// Two-step creation: post order first, then items
  Future<Order> createOrder(Order order) async {
    final res = await api.createOrder(order.toJsonForCreate(items: []));
    if (!res.isOk || res.body is! Map<String, dynamic>) {
      throw Exception('Failed to create order: ${res.statusCode}');
    }
    final createdOrder = Order.fromJson(res.body as Map<String, dynamic>);
    _cache.add(createdOrder);
    return createdOrder;
  }

  // POST /api/order_items
  // Now returns the server’s created OrderItem instead of void.
  Future<OrderItem> createOrderItem(OrderItem item) async {
    // 1) send JSON for creation (omit id/order_id)
    final res = await api.createItem(item.toJsonForCreate());
    print(item.toJsonForCreate());
    if (!res.isOk || res.body is! Map<String, dynamic>) {
      throw Exception('Failed to create order item (${res.statusCode})');
    }

    // 2) parse the newly‐created item from the response JSON
    final Map<String, dynamic> body = res.body as Map<String, dynamic>;
    final created = OrderItem.fromJson(body);

    // 3) cache & return it
    _itemCache.add(created);
    return created;
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) async {
    final res = await api.itemsOfOrder(int.parse(orderId));
    if (res.isOk && res.body is List) {
      return (res.body as List)
          .map((e) => OrderItem.fromJson(e))
          .toList();
    }
    return [];
  }


  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) async {
    final res = await api.orders();
    if (res.isOk && res.body is List) {
      _cache
        ..clear()
        ..addAll((res.body as List).map((e) => Order.fromJson(e as Map<String, dynamic>)));
    }
    return _cache.where((o) {
      if (status != null && o.status != status) return false;
      if (assignedTo != null && o.assignedTo != assignedTo) return false;
      return true;
    }).toList();
  }

  Order? getById(String id) => _cache.firstWhereOrNull((o) => o.orderId == id);

  Future<void> updateOrder(Order order) async {
    final res = await api.updateOrder(int.parse(order.orderId!), order.toJson());
    if (!res.isOk) throw Exception('Failed to update order: ${res.statusCode}');
    final idx = _cache.indexWhere((o) => o.orderId == order.orderId);
    if (idx != -1) _cache[idx] = order;
  }

  Future<void> assignOrder(String orderId, String userId) async {
    final res = await api.assignOrder(int.parse(orderId), {'user_id': int.parse(userId)});
    if (!res.isOk) throw Exception('Failed to assign order: ${res.statusCode}');
    final order = getById(orderId);
    if (order != null) {
      order.assignedTo = userId;
      order.status = OrderStatus.pending;
    }
  }

  bool selfAssign(String orderId, String userId) {
    assignOrder(orderId, userId);
    return true;
  }
}