import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:get/get.dart';
import '../../orders/model/order.dart';
import '../../orders/repository/order_repo.dart';
import '../model/assistant_analytics.dart';

class AssistantAnalyticsController extends GetxController {
  final AnalyticsRepo analyticsRepo;
  final int assistantId;

  AssistantAnalyticsController({
    required this.analyticsRepo,
    required this.assistantId,
  });

  final OrderRepo orderRepo = Get.find<OrderRepo>();

  var analytics = Rxn<AssistantAnalytics>();
  var isLoading = false.obs;
  var recentOrders        = <Order>[].obs;
  var isLoadingRecent     = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    _loadRecentOrders();
  }

  Future<void> _loadRecentOrders() async {
    isLoadingRecent.value = true;
    // fetch 5 most recent orders, descending by ID
    final list = await orderRepo.getOrders(limit: 5);
    recentOrders.assignAll(list);
    isLoadingRecent.value = false;
  }

  Future<void> refreshAll() async {
    await Future.wait([ _load(), _loadRecentOrders() ]);
  }

  Future<void> _load() async {
    isLoading.value = true;
    analytics.value = await analyticsRepo.fetchAssistantAnalytics(assistantId);
    isLoading.value = false;
  }
}
