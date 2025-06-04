import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/data/model/order/order.dart';
import 'package:flutter_boilerplate/data/model/order/order_status.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});

  List<Order> getOrders({OrderStatus? status, String? assignedTo}) {
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
    update();
  }

  void updateOrder(Order order) {
    orderRepo.updateOrder(order);
    update();
  }

  void assignOrder(String orderId, String userId) {
    orderRepo.assignOrder(orderId, userId);
    update();
  }

  bool selfAssign(String orderId) {
    final auth = Get.find<AuthController>();
    final userId = auth.currentUser?.id;
    if (userId == null) return false;
    final res = orderRepo.selfAssign(orderId, userId);
    update();
    return res;
  }
}
