import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:get/get.dart';
import '../../../helper/route_helper.dart';
import '../../auth/service/auth_service.dart';
import '../../finance/model/assistant.dart';
import '../../finance/service/finance_service.dart';

class OrderController extends GetxController {
  final OrderService orderService;
  final AuthService authService;
  final FinanceService financeService;

  OrderController({
    required this.orderService,
    required this.authService,
    required this.financeService,
  });

  Future<Order?> getOrder(String id) => orderService.getOrderById(id);

  // reactive states
  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var filterStatus = Rxn<OrderStatus>();
  var filterAssignedTo = Rxn<int>();
  var assistants = <Assistant>[].obs;

  // new order states
  var newItems = <OrderItem>[].obs;
  var assignedToUserId = Rxn<int>();

  // existing order details
  var items = <OrderItem>[].obs;
  var isLoadingItems = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssistants();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    final list = await orderService.getOrders(
      status: filterStatus.value,
      assignedTo: filterAssignedTo.value,
    );
    orders.assignAll(list);
    isLoading.value = false;
  }

  void setStatusFilter(OrderStatus? status) {
    filterStatus.value = status;
    loadOrders();
  }

  void setAssignedToFilter(int? userId) {
    filterAssignedTo.value = userId;
    loadOrders();
  }

  Future<void> loadAssistants() async {
    assistants.value = await financeService.fetchAssistants();
  }

  Future<List<Order>> getOrders({OrderStatus? status, int? assignedTo}) {
    return orderService.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<void> assignOrder(String orderId, int userId) async {
    try {
      await orderService.assignOrder(orderId, userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign user: $e');
    }
  }

  Future<void> loadItems(String orderId) async {
    isLoadingItems.value = true;
    items.value = await orderService.getItemsOfOrder(orderId);
    isLoadingItems.value = false;
  }

  Future<OrderItem> createOrderItem(OrderItem item) {
    return orderService.createOrderItem(item);
  }

  Future<void> updateOrderItem(OrderItem item, bool isPurchased) async {
    await orderService.updateOrderItem(item);
  }

  Future<void> completeOrder(String orderId) async {
    await orderService.completeOrder(orderId);
  }

  Future<void> deleteOrderItem(OrderItem item) async {
    await orderService.deleteOrderItem(item);
    loadItems(item.orderId.toString());
  }

  void onCreateOrderTapped() {
    newItems.clear();
    assignedToUserId.value = null;
    Get.toNamed(RouteHelper.orderCreate);
  }

  void addItem() {
    newItems.add(OrderItem.empty(orderId: 0));
  }

  void removeItem(int index) {
    newItems.removeAt(index);
  }

  Future<List<Assistant>> getAllAssistants() {
    return financeService.fetchAssistants(withBalance: true);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) {
    return orderService.getItemsOfOrder(orderId);
  }

  Future<void> saveNewOrder() async {
    if (newItems.isEmpty) {
      Get.snackbar('Error', 'Add at least one item.');
      return;
    }

    final order = Order.create(
      createdBy: authService.currentUser!.id.toString(),
      assignedTo: assignedToUserId.value?.toString(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final created = await orderService.createOrderWithItems(order, newItems);
      loadOrders();
      Get.back(result: created);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save order: $e');
    }
  }

  Future<bool> selfAssign(String orderId) async {
    return orderService.selfAssign(orderId, authService.currentUser!.id.toString());
  }
}
