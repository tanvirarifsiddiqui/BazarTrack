import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import '../../orders/model/order.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';
import '../repository/analytics_repo.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepo analyticsRepo;
  final OrderRepo     orderRepo;
  final AuthService   authService;

  AnalyticsController({
    required this.analyticsRepo,
    required this.orderRepo,
    required this.authService,
  });

  var dashboard = Rxn<DashboardMetrics>();
  var reports   = Rxn<ReportsData>();
  var isLoading = false.obs;

  // Recent orders
  var recentOrders        = <Order>[].obs;
  var isLoadingRecent     = false.obs;

  @override
  void onInit() {
    super.onInit();
      _loadAll();
      _loadRecentOrders();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    dashboard.value = await analyticsRepo.fetchDashboard();
    reports.value   = await analyticsRepo.fetchReports();
    isLoading.value = false;
  }

  Future<void> _loadRecentOrders() async {
    isLoadingRecent.value = true;
    // fetch 5 most recent orders, descending by ID
    print(int.parse(authService.currentUser!.id));
    final list = await orderRepo.getOrders(ownerId: int.parse(authService.currentUser!.id),limit: 5);
    recentOrders.assignAll(list);
    isLoadingRecent.value = false;
  }

  /// Public refresh to be called by pull‐to‐refresh
  Future<void> refreshAll() async {
    await Future.wait([ _loadAll(), _loadRecentOrders() ]);
  }

  Future<void> loadDashboardUserInfo() async {
    isLoading.value = true;
    dashboard.value = await analyticsRepo.fetchDashboard();
    isLoading.value = false;
  }

}
