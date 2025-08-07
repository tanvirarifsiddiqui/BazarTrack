// File: lib/features/orders/service/order_service.dart

import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:flutter_boilerplate/features/history/service/history_service.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';

class OrderService extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderService({required this.orderRepo});

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) {
    return orderRepo.getOrders(status: status, assignedTo: assignedTo);
  }

  Order? getOrder(String id) => orderRepo.getById(id);

  /// Create order and items in two steps
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

  Future<void> updateOrder(Order order) async {
    final prev = orderRepo.getById(order.orderId!);
    await orderRepo.updateOrder(order);
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: order.orderId!,
        action: 'updated',
        changedByUserId: Get.find<AuthService>().currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {'before': prev?.toJson(), 'after': order.toJson()},
      ),
    );
    update();
  }

  Future<void> assignOrder(String orderId, String userId) async {
    final prev = orderRepo.getById(orderId);
    await orderRepo.assignOrder(orderId, userId);
    final order = orderRepo.getById(orderId);
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'assigned',
        changedByUserId: Get.find<AuthService>().currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {'before': prev?.toJson(), 'after': order?.toJson()},
      ),
    );
    update();
  }

  Future<bool> selfAssign(String orderId) async {
    final userId = Get.find<AuthService>().currentUser?.id;
    if (userId == null) return false;
    final prev = orderRepo.getById(orderId);
    await orderRepo.assignOrder(orderId, userId);
    final order = orderRepo.getById(orderId);
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'self-assigned',
        changedByUserId: userId,
        timestamp: DateTime.now(),
        dataSnapshot: {'before': prev?.toJson(), 'after': order?.toJson()},
      ),
    );
    update();
    return true;
  }
}