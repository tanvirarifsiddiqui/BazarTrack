import 'package:get/get.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';
import '../repository/analytics_repo.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepo analyticsRepo;
  AnalyticsController({ required this.analyticsRepo });

  var dashboard = Rxn<DashboardMetrics>();
  var reports   = Rxn<ReportsData>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
      loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    dashboard.value = await analyticsRepo.fetchDashboard();
    reports.value   = await analyticsRepo.fetchReports();
    isLoading.value = false;
  }

  Future<void> loadDashboardUserInfo() async {
    isLoading.value = true;
    dashboard.value = await analyticsRepo.fetchDashboard();
    isLoading.value = false;
  }

}
