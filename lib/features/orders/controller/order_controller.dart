import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final OrderService orderService;
  OrderController({required this.orderService});

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) {
    return orderService.getOrders(status: status, assignedTo: assignedTo);
  }

  Order? getOrder(String id) => orderService.getOrder(id);

  void createOrder() {
    orderService.createOrder();
    update();
  }

  void updateOrder(Order order) {
    orderService.updateOrder(order);
    update();
  }

  void assignOrder(String orderId, String userId) {
    orderService.assignOrder(orderId, userId);
    update();
  }

  bool selfAssign(String orderId) {
    final res = orderService.selfAssign(orderId);
    update();
    return res;
  }
}
