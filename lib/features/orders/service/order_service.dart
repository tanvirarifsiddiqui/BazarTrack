// File: lib/features/orders/service/order_service.dart

import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:flutter_boilerplate/features/history/service/history_service.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';

class OrderService extends GetxController implements GetxService {
  final OrderRepo orderRepo;

  OrderService({ required this.orderRepo });

  Future<List<Order>> getOrders({ OrderStatus? status, String? assignedTo }) async {
    return await orderRepo.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) async {
    return await orderRepo.getItemsOfOrder(orderId);
  }

  Future<OrderItem> updateOrderItem(OrderItem item) async {
    final updated = await orderRepo.updateOrderItem(item);

    // record history
    Get.find<HistoryService>().addLog(HistoryLog(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      entityType:      'OrderItem',
      entityId:        updated.id.toString(),
      action:          'updated',
      changedByUserId: Get.find<AuthService>().currentUser!.id.toString(),
      timestamp:       DateTime.now(),
      dataSnapshot:    { 'after': updated.toJson() },
    ));

    return updated;
  }

  Future<void> deleteOrderItem(OrderItem item) async {
    await orderRepo.deleteOrderItem(item.orderId, item.id!);

    Get.find<HistoryService>().addLog(HistoryLog(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      entityType:      'OrderItem',
      entityId:        item.id.toString(),
      action:          'deleted',
      changedByUserId: Get.find<AuthService>().currentUser!.id.toString(),
      timestamp:       DateTime.now(),
      dataSnapshot:    {'before': item.toJson()},
    ));
  }

  Future<void> completeOrder(String orderId) async {
    await orderRepo.completeOrder(orderId);
  }

  Order? getOrder(String id) => orderRepo.getById(id);

  /// Create a single OrderItem + log to history
  Future<OrderItem> createOrderItem(OrderItem item) async {
    final created = await orderRepo.createOrderItem(item);

    // Log creation (void)
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'OrderItem',
        entityId: created.id.toString(),
        action: 'created',
        changedByUserId: Get.find<AuthService>()
            .currentUser
            ?.id
            .toString() ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {'after': created.toJson()},
      ),
    );

    // Notify listeners
    update();

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

    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: createdOrder.orderId!,
        action: 'created',
        changedByUserId: Get.find<AuthService>().currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {'after': createdOrder.toJson()},
      ),
    );

    update();
    return createdOrder;
  }

  /// Update an existing Order + log
  Future<void> updateOrder(Order order) async {
    final previous = orderRepo.getById(order.orderId!);
    await orderRepo.updateOrder(order);

    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: order.orderId!,
        action: 'updated',
        changedByUserId: Get.find<AuthService>().currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': previous?.toJson(),
          'after': order.toJson(),
        },
      ),
    );

    update();
  }

  /// Assign an Order to a user + log
  Future<void> assignOrder(String orderId, String userId) async {
    final previous = orderRepo.getById(orderId);
    await orderRepo.assignOrder(orderId, userId);
    final updatedOrder = orderRepo.getById(orderId);

    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'assigned',
        changedByUserId: Get.find<AuthService>().currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': previous?.toJson(),
          'after': updatedOrder?.toJson(),
        },
      ),
    );

    update();
  }

  /// Self-assign the current user to an Order + log
  Future<bool> selfAssign(String orderId) async {
    final userId = Get.find<AuthService>().currentUser?.id;
    if (userId == null) return false;

    final previous = orderRepo.getById(orderId);
    await orderRepo.assignOrder(orderId, userId);
    final updatedOrder = orderRepo.getById(orderId);

    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'self-assigned',
        changedByUserId: userId,
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': previous?.toJson(),
          'after': updatedOrder?.toJson(),
        },
      ),
    );

    update();
    return true;
  }
}
