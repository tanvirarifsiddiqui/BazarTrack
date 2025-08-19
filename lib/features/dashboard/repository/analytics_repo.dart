import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import '../model/assistant_analytics.dart';
import '../model/dashboard_metrics.dart';
import '../model/monthly_report.dart';

class AnalyticsRepo {
  final BazarTrackApi api;
  AnalyticsRepo({ required this.api });

  Future<DashboardMetrics> fetchDashboard() async {
    final res = await api.dashboard();
    if (res.isOk && res.body is Map<String, dynamic>) {
      return DashboardMetrics.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to load dashboard metrics');
  }

  Future<ReportsData> fetchReports() async {
    final res = await api.reports();
    if (res.isOk && res.body is Map<String, dynamic>) {
      return ReportsData.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to load reports data');
  }

  Future<AssistantAnalytics> fetchAssistantAnalytics(int id) async {
    final res = await api.assistantAnalytics(id);
    if (res.isOk && res.body is Map<String, dynamic>) {
      return AssistantAnalytics.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to load assistant analytics');
  }
}
