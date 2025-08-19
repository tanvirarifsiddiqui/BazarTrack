import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';

class OrderService extends GetxService {
  final OrderRepo orderRepo;

  OrderService({required this.orderRepo});

  Future<List<Order>> getOrders({OrderStatus? status, int? assignedTo}) async {
    return await orderRepo.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) async {
    return await orderRepo.getItemsOfOrder(orderId);
  }

  Future<OrderItem> updateOrderItem(OrderItem item) async {
    final updated = await orderRepo.updateOrderItem(item);

    return updated;
  }

  Future<void> deleteOrderItem(OrderItem item) async {
    await orderRepo.deleteOrderItem(item.orderId, item.id!);
  }

  Future<void> completeOrder(String orderId) async {
    await orderRepo.completeOrder(orderId);
  }

  Future<Order?> getOrderById(String id) => orderRepo.getOrderById(id);

  /// Create a single OrderItem + log to history
  Future<OrderItem> createOrderItem(OrderItem item) async {
    final created = await orderRepo.createOrderItem(item);

    return created;
  }

  /// Create Order + its items in two steps, then log
  Future<Order> createOrderWithItems(Order order, List<OrderItem> items) async {
    final createdOrder = await orderRepo.createOrder(order);
    final serverId = int.parse(createdOrder.orderId!);

    for (var item in items) {
      final updatedItem = item.copyWith(orderId: serverId);
      await orderRepo.createOrderItem(updatedItem);
    }
    return createdOrder;
  }

  /// Update an existing Order + log
  Future<void> updateOrder(Order order) async {
    // final previous = orderRepo.getById(order.orderId!);
    await orderRepo.updateOrder(order);
  }

  /// Assign an Order to a user + log
  Future<void> assignOrder(String orderId, int userId) async {
    await orderRepo.assignOrder(orderId, userId);
  }

  /// Self-assign the current user to an Order + log
  Future<bool> selfAssign(String orderId, String userId) async {
    await orderRepo.assignOrder(orderId, int.parse(userId));
    return true;
  }
}
