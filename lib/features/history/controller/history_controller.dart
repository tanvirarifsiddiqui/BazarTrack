// lib/features/history/controller/history_controller.dart

import 'package:flutter_boilerplate/features/history/repository/history_repo.dart';
import 'package:get/get.dart';
import '../model/history_log.dart';

class HistoryController extends GetxController {
  final HistoryRepo historyRepo;
  HistoryController({ required this.historyRepo });

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
    allLogs.value     = await historyRepo.getAll();
    isLoadingAll.value = false;
  }

  Future<void> loadOrders() async {
    isLoadingOrder.value = true;
    orderLogs.value      = await historyRepo.getByEntity('order');
    isLoadingOrder.value = false;
  }

  Future<void> loadItems() async {
    isLoadingItem.value = true;
    itemLogs.value      = await historyRepo.getByEntity('order_item');
    isLoadingItem.value = false;
  }

  Future<void> loadPayments() async {
    isLoadingPayment.value = true;
    paymentLogs.value      = await historyRepo.getByEntity('payment');
    isLoadingPayment.value = false;
  }

  Future<void> loadByEntity(String entity) async {
    isLoading.value = true;
    logs.value = await historyRepo.getByEntity(entity);
    isLoading.value = false;
  }

  Future<void> loadByEntityId(String entity, int id) async {
    isLoading.value = true;
    logs.value = await historyRepo.getByEntityId(entity, id);
    isLoading.value = false;
  }
}
