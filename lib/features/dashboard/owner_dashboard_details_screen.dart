import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/analytics_controller.dart';
import 'package:flutter_boilerplate/features/finance/controller/finance_controller.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:get/get.dart';
import '../../util/colors.dart';
import 'components/reports_summary.dart';
import 'components/stats_summary.dart';
import 'components/wallet_summary.dart';

class OwnerDashboardDetails extends StatelessWidget {
  const OwnerDashboardDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalyticsController>();
    final financeCtrl = Get.find<FinanceController>();
    final theme = Theme.of(context);
    final spacer = const SizedBox(height: 10);

    return Scaffold(
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final dash = ctrl.dashboard.value!;
        final rep  = ctrl.reports.value!;

        return RefreshIndicator(
          color: AppColors.primary,
            onRefresh: () async => ctrl.loadAll(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.scaffoldPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatsSummary(
                  totalOrders:    dash.totalOrders,
                  totalUsers:     dash.totalUsers,
                  totalPayments:     dash.totalPayments,
                  balance:      dash.totalExpense,
                  theme: theme,
                ),
                spacer,
                WalletSummary(
                  theme: theme,
                  assistants: financeCtrl.assistants,
                ),
                spacer,
                ReportsSummary(reports: rep, theme: theme),
              ],
            ),
          ),
        );
      }),
    );
  }

}
