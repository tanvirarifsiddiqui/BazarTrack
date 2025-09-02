import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/assistant_analytics_controller.dart';
import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:flutter_boilerplate/features/finance/model/assistant.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:get/get.dart';
import '../../util/colors.dart';
import '../auth/model/role.dart';
import 'components/assistant_reports_chart.dart';
import 'components/assistant_stats_summary.dart';
import 'components/recent_orders.dart';

class AssistantDashboardDetails extends StatelessWidget {
  final Assistant assistant;

  const AssistantDashboardDetails({super.key, required this.assistant});

  @override
  Widget build(BuildContext context) {
    // inside AssistantDashboardDetails.build:
    final ctrl = Get.put(
      AssistantAnalyticsController(
        analyticsRepo: Get.find<AnalyticsRepo>(),
        orderRepo: Get.find<OrderRepo>(),
        authService: Get.find(),
        assistantId: assistant.id,
      ),
      tag: 'assistant_${assistant.id}', // << unique tag
    );
    final isOwner = Get.find<AuthService>().currentUser?.role == UserRole.owner;
    final theme = Theme.of(context);
    const spacer = SizedBox(height: 8);

    return Scaffold(
      appBar:
          isOwner ? CustomAppBar(title: "${assistant.name}'s Dashboard") : null,
      body: Obx(() {
        if (ctrl.isLoading.value || ctrl.analytics.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = ctrl.analytics.value!; // now safe
        return RefreshIndicator(

          color: AppColors.primary,
          onRefresh: () async {
            await ctrl.refreshAll();
          },
          child: SingleChildScrollView(
            // THIS IS THE KEY: allow overscroll even when content is short
            physics: const AlwaysScrollableScrollPhysics(),
            primary: true,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                AssistantStatsSummary(
                  totalOrders: data.totalOrders,
                  totalExpense: data.totalExpense,
                  theme: theme,
                ),
                spacer,
                AssistantReportsChart(data: data, theme: theme),
                SizedBox(height: 12),
                RecentOrdersList(
                  isOwner: false,
                  recentOrders: ctrl.recentOrders,
                  isLoadingRecent: ctrl.isLoadingRecent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
