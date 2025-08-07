// File: lib/features/orders/controller/order_controller.dart

import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:get/get.dart';
import '../../../helper/route_helper.dart';
import '../../auth/service/auth_service.dart';

class OrderController extends GetxController {
  final OrderService orderService;
  final AuthService _auth = Get.find();

  List<OrderItem> newItems = [];
  String assignedToUserId = '';

  OrderController({required this.orderService});

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) {
    return orderService.getOrders(status: status, assignedTo: assignedTo);
  }

  Order? getOrder(String id) => orderService.getOrder(id);

  void onCreateOrderTapped() {
    newItems = [];
    assignedToUserId = _auth.currentUser?.id ?? '';
    Get.toNamed(RouteHelper.orderCreate);
  }

  void addItem() {
    newItems.add(OrderItem.empty(orderId: 0));
    update();
  }

  void removeItem(int index) {
    newItems.removeAt(index);
    update();
  }

  Future<void> saveNewOrder() async {
    if (newItems.isEmpty) {
      Get.snackbar('Error', 'Add at least one item.');
      return;
    }

    final order = Order.create(
      createdBy: _auth.currentUser!.id.toString(),
      assignedTo: assignedToUserId,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final created = await orderService.createOrderWithItems(order, newItems);
      Get.back(result: created);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save order: $e');
    }
  }

  Future<bool> selfAssign(String orderId) async {
    final res = await orderService.selfAssign(orderId);
    update();
    return res;
  }
}