import 'package:flutter_boilerplate/features/dashboard/controller/analytics_controller.dart';
import 'package:flutter_boilerplate/features/finance/repository/finance_repo.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import '../../auth/service/auth_service.dart';
import '../../finance/model/assistant.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;
  final AuthService authService;
  final FinanceRepo financeRepo;

  static const _pageSize = 30; // max 30
  OrderController({
    required this.orderRepo,
    required this.authService,
    required this.financeRepo,
  });

  Future<Order?> getOrder(String id) => orderRepo.getOrderById(id);

  bool isOwner = false;
  int? ownerId;

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

  //for pagination
  var isInitialLoading = false.obs;
  var isLoadingMore  = false.obs;
  var hasMore        = true.obs;

  // NEW reactive flag
  var isUnassignedTab = false.obs;

  Future<void> loadInitial() async {
    hasMore.value = true;
    orders.clear();
    isInitialLoading.value = true;
    await _fetchPage(reset: true);
    isInitialLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _fetchPage();
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({ bool reset = false }) async {
    final cursor = reset || orders.isEmpty ? null : orders.last.id;

    final page = await orderRepo.getOrders(
      ownerId:     isOwner ? int.parse(authService.currentUser!.id) : null,
      status:      filterStatus.value,
      assignedTo:  filterAssignedTo.value,
      unassigned:  isUnassignedTab.value,  // PASS FLAG
      limit:       _pageSize,
      cursor:      cursor,
    );

    if (page.length < _pageSize) hasMore.value = false;
    orders.addAll(page);
  }


  void setStatusFilter(OrderStatus? status) {
    filterStatus.value = status;
    loadInitial();
  }

  void setAssignedToFilter(int? userId) {
    filterAssignedTo.value = userId;
    loadInitial();
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
  }

  void addItem() {
    newItems.add(OrderItem.empty(orderId: 0));
  }

  void removeItem(int index) {
    newItems.removeAt(index);
  }

  Future<void> getAllAssistants() async {
    assistants.value =await financeRepo.getAssistants(withBalance: true);
  }

  Future<List<Assistant>> getAllAssistantsWithCurrentBalance() {
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
      createdBy: authService.currentUser!.id.toString(), //for owner
      assignedTo: assignedToUserId.value?.toString(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final created = await orderRepo.createOrderWithItems(order, newItems);
      loadInitial();
      Get.find<AnalyticsController>().refreshAll();
      Get.back(result: created);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save order: $e');
    }
  }

  Future<bool> selfAssign(String orderId) async {
    return orderRepo.selfAssign(orderId, int.parse(authService.currentUser!.id)); //for assistant
  }
// New tab helper methods:
  void setMyOrdersFilter() {
    isUnassignedTab.value   = false;
    filterAssignedTo.value  = int.parse(authService.currentUser!.id);
    loadInitial();
  }

  void setUnassignedFilter() {
    isUnassignedTab.value   = true;
    filterAssignedTo.value  = null;
    filterStatus.value      = null;  // clear any status filter
    loadInitial();
  }
}
