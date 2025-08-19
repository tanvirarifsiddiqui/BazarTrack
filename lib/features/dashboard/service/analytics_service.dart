import 'package:get/get.dart';
import '../model/assistant_analytics.dart';
import '../repository/analytics_repo.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';

class AnalyticsService extends GetxService {
  final AnalyticsRepo repo;
  AnalyticsService({ required this.repo });

  Future<DashboardMetrics> getDashboard() => repo.fetchDashboard();

  Future<ReportsData> getReports() => repo.fetchReports();

  Future<AssistantAnalytics> getAssistantAnalytics(int id) =>
      repo.fetchAssistantAnalytics(id);

}
