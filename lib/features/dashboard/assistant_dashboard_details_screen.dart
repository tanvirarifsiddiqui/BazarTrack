import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/assistant_analytics_controller.dart';
import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:get/get.dart';
import 'components/assistant_reports_chart.dart';
import 'components/assistant_stats_summary.dart';

class AssistantDashboardDetails extends StatelessWidget {
  final int assistantId;

  const AssistantDashboardDetails({Key? key, required this.assistantId})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.put(AssistantAnalyticsController(analyticsRepo: Get.find<AnalyticsRepo>(), assistantId: assistantId));
    final theme = Theme.of(context);
    const spacer = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text("Assistant Dashboard")),
      body: Obx(() {
      if (ctrl.isLoading.value || ctrl.analytics.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = ctrl.analytics.value!; // now safe
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AssistantStatsSummary(
              totalOrders:  data.totalOrders,
              totalRevenue: data.totalRevenue,
              theme:        theme,
            ),
            spacer,
            AssistantReportsChart(
              data:  data,
              theme: theme,
            ),
          ],
        ),
      );
    }),

    );
  }
}
