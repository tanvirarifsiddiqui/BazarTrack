// lib/features/dashboard/screens/owner_dashboard_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/analytics_controller.dart';
import 'package:get/get.dart';
import 'components/reports_summary.dart';
import 'components/stats_summary.dart';

class OwnerDashboardDetails extends StatelessWidget {
  const OwnerDashboardDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalyticsController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final dash = ctrl.dashboard.value!;
        final rep  = ctrl.reports.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              StatsSummary(
                totalOrders:    dash.totalOrders,
                totalUsers:     dash.totalUsers,
                totalPayments:     dash.totalPayments,
                balance:      dash.totalRevenue,
                theme: theme,
              ),

              const SizedBox(height: 24),

              ReportsSummary(reports: rep, theme: theme),
            ],
          ),
        );
      }),
    );
  }


}
