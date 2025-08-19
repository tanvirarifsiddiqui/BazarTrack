import 'package:flutter_boilerplate/features/finance/repository/finance_repo.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import '../../../helper/route_helper.dart';
import '../../auth/service/auth_service.dart';
import '../../finance/model/assistant.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;
  final AuthService authService;
  final FinanceRepo financeRepo;

  OrderController({
    required this.orderRepo,
    required this.authService,
    required this.financeRepo,
  });

  Future<Order?> getOrder(String id) => orderRepo.getOrderById(id);

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
    getAllAssistants();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    final list = await orderRepo.getOrders(
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

  Future<List<Order>> getOrders({OrderStatus? status, int? assignedTo}) {
    return orderRepo.getOrders(status: status, assignedTo: assignedTo);
  }

  Future<void> assignOrder(String orderId, int userId) async {
    try {
      await orderRepo.assignOrder(orderId, userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign user: $e');
    }
  }

  Future<void> loadItems(String orderId) async {
    isLoadingItems.value = true;
    items.value = await orderRepo.getItemsOfOrder(orderId);
    isLoadingItems.value = false;
  }

  Future<OrderItem> createOrderItem(OrderItem item) {
    return orderRepo.createOrderItem(item);
  }

  Future<void> updateOrderItem(OrderItem item, bool isPurchased) async {
    await orderRepo.updateOrderItem(item);
  }

  Future<void> completeOrder(String orderId) async {
    await orderRepo.completeOrder(orderId);
  }

  Future<void> deleteOrderItem(OrderItem item) async {
    await orderRepo.deleteOrderItem(item.orderId, item.id!);
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
    return financeRepo.getAssistants(withBalance: true);
  }

  Future<List<OrderItem>> getItemsOfOrder(String orderId) {
    return orderRepo.getItemsOfOrder(orderId);
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
      final created = await orderRepo.createOrderWithItems(order, newItems);
      loadOrders();
      Get.back(result: created);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save order: $e');
    }
  }

  Future<bool> selfAssign(String orderId) async {
    return orderRepo.selfAssign(orderId, int.parse(authService.currentUser!.id));
  }
}
