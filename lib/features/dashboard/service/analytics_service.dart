import 'package:get/get.dart';
import '../repository/analytics_repo.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';

class AnalyticsService extends GetxService {
  final AnalyticsRepo repo;
  AnalyticsService({ required this.repo });

  Future<DashboardMetrics> getDashboard() => repo.fetchDashboard();

  Future<ReportsData> getReports() => repo.fetchReports();
}
