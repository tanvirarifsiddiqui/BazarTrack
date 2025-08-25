import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/assistant_analytics_controller.dart';
import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:flutter_boilerplate/features/finance/model/assistant.dart';
import 'package:get/get.dart';
import '../auth/model/role.dart';
import 'components/assistant_reports_chart.dart';
import 'components/assistant_stats_summary.dart';

class AssistantDashboardDetails extends StatelessWidget {
  final Assistant assistant;

  const AssistantDashboardDetails({Key? key, required this.assistant})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.put(AssistantAnalyticsController(analyticsRepo: Get.find<AnalyticsRepo>(), assistantId: assistant.id));
    final isOwner = Get.find<AuthService>().currentUser?.role == UserRole.owner;
    final theme = Theme.of(context);
    const spacer = SizedBox(height: 10);

    return Scaffold(
      appBar: isOwner?CustomAppBar(title: "${assistant.name}'s Dashboard"):null,
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
              totalExpense: data.totalExpense,
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
