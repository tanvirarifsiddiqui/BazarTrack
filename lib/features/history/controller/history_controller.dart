// lib/features/history/controller/history_controller.dart

import 'package:get/get.dart';
import '../model/history_log.dart';
import '../service/history_service.dart';

class HistoryController extends GetxController {
  final HistoryService historyService;
  HistoryController({ required this.historyService });

  // Reactive lists for each tab
  var allLogs        = <HistoryLog>[].obs;
  var orderLogs      = <HistoryLog>[].obs;
  var itemLogs       = <HistoryLog>[].obs;
  var paymentLogs    = <HistoryLog>[].obs;

  var logs = <HistoryLog>[].obs;
  var isLoading = false.obs;

  // Loading flags
  var isLoadingAll     = false.obs;
  var isLoadingOrder   = false.obs;
  var isLoadingItem    = false.obs;
  var isLoadingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    loadOrders();
    loadItems();
    loadPayments();
  }

  Future<void> loadAll() async {
    isLoadingAll.value = true;
    allLogs.value     = await historyService.fetchAll();
    isLoadingAll.value = false;
  }

  Future<void> loadOrders() async {
    isLoadingOrder.value = true;
    orderLogs.value      = await historyService.fetchByEntity('order');
    isLoadingOrder.value = false;
  }

  Future<void> loadItems() async {
    isLoadingItem.value = true;
    itemLogs.value      = await historyService.fetchByEntity('order_item');
    isLoadingItem.value = false;
  }

  Future<void> loadPayments() async {
    isLoadingPayment.value = true;
    paymentLogs.value      = await historyService.fetchByEntity('payment');
    isLoadingPayment.value = false;
  }

  Future<void> loadByEntity(String entity) async {
    isLoading.value = true;
    logs.value = await historyService.fetchByEntity(entity);
    isLoading.value = false;
  }

  Future<void> loadByEntityId(String entity, int id) async {
    isLoading.value = true;
    logs.value = await historyService.fetchByEntityId(entity, id);
    isLoading.value = false;
  }
}
