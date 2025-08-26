// lib/features/history/controller/history_controller.dart

import 'package:get/get.dart';
import '../model/history_log.dart';
import '../repository/history_repo.dart';

class HistoryController extends GetxController {
  final HistoryRepo historyRepo;
  static const _pageSize = 30;

  HistoryController({ required this.historyRepo });

  // Data lists
  var allLogs      = <HistoryLog>[].obs;
  var orderLogs    = <HistoryLog>[].obs;
  var itemLogs     = <HistoryLog>[].obs;
  var paymentLogs  = <HistoryLog>[].obs;

  var logs = <HistoryLog>[].obs;
  var isLoading = false.obs;

  // Loading flags
  var isLoadingAll     = false.obs;
  var isLoadingOrder   = false.obs;
  var isLoadingItem    = false.obs;
  var isLoadingPayment = false.obs;

  // Pagination states
  var allCursor     = RxnInt();
  var orderCursor   = RxnInt();
  var itemCursor    = RxnInt();
  var paymentCursor = RxnInt();

  var allHasMore     = true.obs;
  var orderHasMore   = true.obs;
  var itemHasMore    = true.obs;
  var paymentHasMore = true.obs;

  var allLoadingMore     = false.obs;
  var orderLoadingMore   = false.obs;
  var itemLoadingMore    = false.obs;
  var paymentLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll(initial: true);
    _loadOrders(initial: true);
    _loadItems(initial: true);
    _loadPayments(initial: true);
  }

  // -- ALL --

  Future<void> _loadAll({ bool initial = false }) async {
    if (initial) {
      allHasMore.value = true;
      allCursor.value = null;
      allLogs.clear();
    }
    if (!allHasMore.value) return;

    isLoadingAll.value = initial;
    allLoadingMore.value = !initial;
    final page = await historyRepo.getAll(
      limit:  _pageSize,
      cursor: allCursor.value,
    );
    allLogs.addAll(page);
    if (page.length < _pageSize) allHasMore.value = false;
    allCursor.value = page.isNotEmpty ? page.last.id : allCursor.value;
    isLoadingAll.value = false;
    allLoadingMore.value = false;
  }

  void loadMoreAll() => _loadAll(initial: false);
  void refreshAll()  => _loadAll(initial: true);

  // -- ORDERS --

  Future<void> _loadOrders({ bool initial = false }) async {
    if (initial) {
      orderHasMore.value = true;
      orderCursor.value = null;
      orderLogs.clear();
    }
    if (!orderHasMore.value) return;

    isLoadingOrder.value = initial;
    orderLoadingMore.value = !initial;
    final page = await historyRepo.getByEntity(
      'order',
      limit:  _pageSize,
      cursor: orderCursor.value,
    );
    orderLogs.addAll(page);
    if (page.length < _pageSize) orderHasMore.value = false;
    orderCursor.value = page.isNotEmpty ? page.last.id : orderCursor.value;
    isLoadingOrder.value = false;
    orderLoadingMore.value = false;
  }

  void loadMoreOrders() => _loadOrders(initial: false);
  void refreshOrders()  => _loadOrders(initial: true);

  // -- ITEMS --

  Future<void> _loadItems({ bool initial = false }) async {
    if (initial) {
      itemHasMore.value = true;
      itemCursor.value = null;
      itemLogs.clear();
    }
    if (!itemHasMore.value) return;

    isLoadingItem.value = initial;
    itemLoadingMore.value = !initial;
    final page = await historyRepo.getByEntity(
      'order_item',
      limit:  _pageSize,
      cursor: itemCursor.value,
    );
    itemLogs.addAll(page);
    if (page.length < _pageSize) itemHasMore.value = false;
    itemCursor.value = page.isNotEmpty ? page.last.id : itemCursor.value;
    isLoadingItem.value = false;
    itemLoadingMore.value = false;
  }

  void loadMoreItems() => _loadItems(initial: false);
  void refreshItems()  => _loadItems(initial: true);

  // -- PAYMENTS --

  Future<void> _loadPayments({ bool initial = false }) async {
    if (initial) {
      paymentHasMore.value = true;
      paymentCursor.value = null;
      paymentLogs.clear();
    }
    if (!paymentHasMore.value) return;

    isLoadingPayment.value = initial;
    paymentLoadingMore.value = !initial;
    final page = await historyRepo.getByEntity(
      'payment',
      limit:  _pageSize,
      cursor: paymentCursor.value,
    );
    paymentLogs.addAll(page);
    if (page.length < _pageSize) paymentHasMore.value = false;
    paymentCursor.value = page.isNotEmpty ? page.last.id : paymentCursor.value;
    isLoadingPayment.value = false;
    paymentLoadingMore.value = false;
  }

  void loadMorePayments() => _loadPayments(initial: false);
  void refreshPayments()  => _loadPayments(initial: true);

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
