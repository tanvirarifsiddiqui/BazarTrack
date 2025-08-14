// File: lib/features/orders/controller/order_controller.dart

import 'package:flutter_boilerplate/features/finance/controller/assistant_finance_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:get/get.dart';
import '../../../helper/route_helper.dart';
import '../../auth/service/auth_service.dart';
import '../../finance/model/assistant.dart';
import '../../finance/service/finance_service.dart';
import '../../history/model/history_log.dart';
import '../../history/service/history_service.dart';

class OrderController extends GetxController {
  final OrderService orderService;
  final AuthService _auth = Get.find();
  Order? getOrder(String id) => orderService.getOrder(id);

  List<OrderItem> newItems = [];
  int? assignedToUserId;
  List<OrderItem> items = [];
  bool isLoadingItems = false;
  var assistants = <Assistant>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAssistants();
  }

  Future<void> loadAssistants() async {
    assistants.value = await Get.find<FinanceService>().fetchAssistants();
  }

  OrderController({required this.orderService});

  Future<List<Order>> getOrders({OrderStatus? status, int? assignedTo}) {
    return orderService.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) {
    return orderService.getItemsOfOrder(orderId);
  }

  void assignOrder(String orderId, String userId) {
    orderService.assignOrder(orderId, int.parse(userId));
    loadItems(orderId);
  }

  void loadItems(String orderId) async {
    isLoadingItems = true;
    update(); // show loader
    items = await orderService.getItemsOfOrder(orderId);
    isLoadingItems = false;
    update(); // refresh list
  }

  Future<OrderItem> createOrderItem(OrderItem item) {
    if (item.actualCost != null && item.status == OrderItemStatus.purchased) {
      // addDebitForAssistant(int.parse(_auth.currentUser!.id), item.actualCost!);
      // Get.find<AssistantFinanceController>().loadWalletForAssistant(int.parse(_auth.currentUser!.id));
    }
    return orderService.createOrderItem(item);
  }

  // Update an existing item, log before/after, then refresh list
  Future<void> updateOrderItem(OrderItem item, bool isPurchased) async {
    // 1) take a snapshot of "before"
    final beforeList = await orderService.getItemsOfOrder(
      item.orderId.toString(),
    );

    // 2) actually update and get the updated object
    final updated = await orderService.updateOrderItem(item);
    if (item.actualCost != null) {
      // addDebitForAssistant(int.parse(_auth.currentUser!.id), item.actualCost!);
      await Get.find<AssistantFinanceController>().loadWalletForAssistant(
        int.parse(_auth.currentUser!.id),
      );
    }

    // 3) log both before & after
    Get.find<HistoryService>().addLog(
      HistoryLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'OrderItem',
        entityId: updated.id.toString(),
        action: 'updated',
        changedByUserId: Get.find<AuthService>().currentUser!.id.toString(),
        timestamp: DateTime.now(),
        dataSnapshot: {
          'before': beforeList.map((i) => i.toJson()).toList(),
          'after': updated.toJson(),
        },
      ),
    );

    // 4) reload your visible list
    loadItems(item.orderId.toString());
  }

  //function: Assistant Credit payment for actual cost
  // Future<void> addDebitForAssistant(int assistantId, double amount) async {
  //   final finance = Finance(
  //     userId: assistantId,
  //     amount: amount,
  //     type: 'debit',
  //     createdAt: DateTime.now(),
  //   );
  //   await Get.find<AssistantFinanceService>().recordPayment(finance);
  // }

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
        dataSnapshot: {'after': getOrder(orderId)?.toJson()},
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
    assignedToUserId = null;
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

    print('This is Assigned User Id: $assignedToUserId');
    final order = Order.create(
      createdBy: _auth.currentUser!.id.toString(),
      assignedTo: assignedToUserId?.toString(), // <-- null-safe for proper response
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
