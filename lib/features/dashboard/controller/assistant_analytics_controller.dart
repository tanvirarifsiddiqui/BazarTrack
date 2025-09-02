import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:get/get.dart';
import '../../auth/model/role.dart';
import '../../orders/model/order.dart';
import '../../orders/repository/order_repo.dart';
import '../model/assistant_analytics.dart';

class AssistantAnalyticsController extends GetxController {
  final AnalyticsRepo analyticsRepo;
  final int assistantId;
  final OrderRepo orderRepo;
  final AuthService authService;
  var isOwner = false;

  AssistantAnalyticsController({
    required this.analyticsRepo,
    required this.orderRepo,
    required this.assistantId,
    required this.authService,
  });

  var analytics = Rxn<AssistantAnalytics>();
  var isLoading = false.obs;
  var recentOrders = <Order>[].obs;
  var isLoadingRecent = false.obs;

  @override
  void onInit() {
    isOwner = authService.currentUser?.role == UserRole.owner;
    super.onInit();
    if (isOwner) {
      _load();
    } else {
      _loadAssistantSelf();
    }
    _loadRecentOrders();
  }

  Future<void> _loadRecentOrders() async {
    isLoadingRecent.value = true;
    // fetch 5 most recent orders, descending by ID
    final list = await orderRepo.getOrders(assignedTo: assistantId, limit: 5);
    recentOrders.assignAll(list);
    isLoadingRecent.value = false;
  }

  Future<void> refreshAll() async {
    final futures = <Future<void>>[];
    if (isOwner) {
      futures.add(_load());
    } else {
      futures.add(_loadAssistantSelf());
    }
    futures.add(_loadRecentOrders());

    await Future.wait(futures);
  }

  Future<void> _load() async {
    isLoading.value = true;
    analytics.value = await analyticsRepo.fetchAssistantAnalytics(assistantId);
    isLoading.value = false;
  }

  Future<void> _loadAssistantSelf() async {
    isLoading.value = true;
    analytics.value = await analyticsRepo.fetchAssistantSelfAnalytics();
    isLoading.value = false;
  }
}
