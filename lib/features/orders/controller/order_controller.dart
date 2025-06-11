import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/data/model/history/history_log.dart';
import 'package:flutter_boilerplate/features/history/controller/history_controller.dart';
import 'package:flutter_boilerplate/data/model/order/order.dart';
import 'package:flutter_boilerplate/data/model/order/order_status.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) {
    return orderRepo.getOrders(status: status, assignedTo: assignedTo);
  }

  Order? getOrder(String id) => orderRepo.getById(id);

  void createOrder() {
    final auth = Get.find<AuthController>();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      orderId: id,
      createdBy: auth.currentUser?.id ?? '',
      createdAt: DateTime.now(),
    );
    orderRepo.createOrder(order);
    Get.find<HistoryController>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: id,
        action: 'created',
        changedByUserId: auth.currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {'after': order.toJson()},
      ),
    );
    update();
  }

  void updateOrder(Order order) {
    final prev = orderRepo.getById(order.orderId);
    orderRepo.updateOrder(order);
    final auth = Get.find<AuthController>();
    Get.find<HistoryController>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: order.orderId,
        action: 'updated',
        changedByUserId: auth.currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': prev?.toJson(),
          'after': order.toJson(),
        },
      ),
    );
    update();
  }

  void assignOrder(String orderId, String userId) {
    final prev = orderRepo.getById(orderId);
    orderRepo.assignOrder(orderId, userId);
    final order = orderRepo.getById(orderId);
    final auth = Get.find<AuthController>();
    Get.find<HistoryController>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'assigned',
        changedByUserId: auth.currentUser?.id ?? '',
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': prev?.toJson(),
          'after': order?.toJson(),
        },
      ),
    );
    update();
  }

  bool selfAssign(String orderId) {
    final auth = Get.find<AuthController>();
    final userId = auth.currentUser?.id;
    if (userId == null) return false;
    final prev = orderRepo.getById(orderId);
    final res = orderRepo.selfAssign(orderId, userId);
    final order = orderRepo.getById(orderId);
    Get.find<HistoryController>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'self-assigned',
        changedByUserId: userId,
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': prev?.toJson(),
          'after': order?.toJson(),
        },
      ),
    );
    update();
    return res;
  }
}
