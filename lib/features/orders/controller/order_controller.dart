// File: lib/features/orders/controller/order_controller.dart

import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:get/get.dart';
import '../../../helper/route_helper.dart';
import '../../auth/service/auth_service.dart';
import '../../history/model/history_log.dart';
import '../../history/service/history_service.dart';

class OrderController extends GetxController {
  final OrderService orderService;
  final AuthService _auth = Get.find();
  Order? getOrder(String id) => orderService.getOrder(id);

  List<OrderItem> newItems = [];
  String assignedToUserId = '';
  List<OrderItem> items = [];
  bool isLoadingItems = false;

  OrderController({required this.orderService});

  Future<List<Order>> getOrders({OrderStatus? status, String? assignedTo}) {
    return orderService.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) {
    return orderService.getItemsOfOrder(orderId);
  }

  void assignOrder(String orderId, String userId) {
    orderService.assignOrder(orderId, userId);
    loadItems(orderId);
  }

  void loadItems(String orderId) async {
    isLoadingItems = true;
    update();  // show loader
    items = await orderService.getItemsOfOrder(orderId);
    isLoadingItems = false;
    update();  // refresh list
  }


  // Update an existing item, log before/after, then refresh list
  Future<void> updateOrderItem(OrderItem item) async {
    // 1) take a snapshot of "before"
    final beforeList = await orderService.getItemsOfOrder(item.orderId.toString());

    // 2) actually update and get the updated object
    final updated = await orderService.updateOrderItem(item);

    // 3) log both before & after
    Get.find<HistoryService>().addLog(HistoryLog(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      entityType:      'OrderItem',
      entityId:        updated.id.toString(),
      action:          'updated',
      changedByUserId: Get.find<AuthService>().currentUser!.id.toString(),
      timestamp:       DateTime.now(),
      dataSnapshot:    {
        'before': beforeList.map((i) => i.toJson()).toList(),
        'after':  updated.toJson(),
      },
    ));

    // 4) reload your visible list
    loadItems(item.orderId.toString());
  }



  Future<void> completeOrder(String orderId) async {
    await orderService.completeOrder(orderId);
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'Order',
        entityId: orderId,
        action: 'completed',
        changedByUserId: Get.find<AuthService>().currentUser!.id.toString(),
        timestamp: DateTime.now(),
        dataSnapshot: {
          'after': getOrder(orderId)?.toJson(),
        },
      ),
    );
    update();
  }

  Future<void> deleteOrderItem(OrderItem item) async {
    await orderService.deleteOrderItem(item);
    loadItems(item.orderId.toString());
  }

  void onCreateOrderTapped() {
    newItems = [];
    assignedToUserId = _auth.currentUser?.id ?? '';
    Get.toNamed(RouteHelper.orderCreate);
  }

  void addItem() {
    newItems.add(OrderItem.empty(orderId: 0));
    update();
  }

  Future<OrderItem> createOrderItem(OrderItem item) {
    return orderService.createOrderItem(item);
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