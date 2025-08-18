import 'package:get/get.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';
import '../service/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService service;
  AnalyticsController({ required this.service });

  var dashboard = Rxn<DashboardMetrics>();
  var reports   = Rxn<ReportsData>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    dashboard.value = await service.getDashboard();
    reports.value   = await service.getReports();
    isLoading.value = false;
  }
}
