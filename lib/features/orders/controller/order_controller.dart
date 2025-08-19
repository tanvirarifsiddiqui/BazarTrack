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
  final AuthService _auth = Get.find();
  Future<Order?> getOrder(String id) => orderService.getOrderById(id);

  // reactive list + loading flag
  var orders       = <Order>[].obs;
  var isLoading    = false.obs;

  // current filters
  var filterStatus     = Rxn<OrderStatus>();
  var filterAssignedTo = Rxn<int>();

  List<OrderItem> newItems = [];
  int? assignedToUserId;
  List<OrderItem> items = [];
  bool isLoadingItems = false;
  var assistants = <Assistant>[].obs;

  Future<List<Assistant>> getAllAssistants() {
    return Get.find<FinanceService>().fetchAssistants(withBalance: true);
  }

  @override
  void onInit() {
    super.onInit();
    loadAssistants();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;

    final list = await orderService.getOrders(
      status:     filterStatus.value,
      assignedTo: filterAssignedTo.value,
    );

    orders.assignAll(list);
    isLoading.value = false;
  }

  /// Called by the UI when user picks a new status
  void setStatusFilter(OrderStatus? status) {
    filterStatus.value = status;
    loadOrders();
  }

  /// Optionally call this to filter unassigned vs a specific assistant
  void setAssignedToFilter(int? userId) {
    filterAssignedTo.value = userId;
    loadOrders();
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

  Future<void> assignOrder(String orderId, int userId) async {
    try {
      await orderService.assignOrder(orderId, userId);
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign user: $e');
    }
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
    await orderService.updateOrderItem(item);
    // if (item.actualCost != null && isPurchased == false) {
    //   // addDebitForAssistant(int.parse(_auth.currentUser!.id), item.actualCost!);
    //   await Get.find<AssistantFinanceController>().loadWalletForAssistant(
    //     int.parse(_auth.currentUser!.id),
    //   );
    // }
    // loadItems(item.orderId.toString());
  }



  Future<void> completeOrder(String orderId) async {
    await orderService.completeOrder(orderId);

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
    update(['newOrder']);
  }

  void removeItem(int index) {
    newItems.removeAt(index);
    update(['newOrder']);
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
      update();
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
