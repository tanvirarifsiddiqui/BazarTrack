import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import '../finance/controller/finance_controller.dart';
import 'components/recent_orders.dart';
import 'components/reports_summary.dart';
import 'components/stats_summary.dart';
import 'components/wallet_summary.dart';
import 'controller/analytics_controller.dart';

class OwnerDashboardDetails extends StatelessWidget {
  const OwnerDashboardDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalyticsController>();
    final financeCtrl = Get.find<FinanceController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            financeCtrl.loadAssistants();
            await ctrl.refreshAll();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.scaffoldPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ─── Stats ────────────────────────────
                StatsSummary(
                  totalOrders: ctrl.dashboard.value!.totalOrders,
                  totalUsers: ctrl.dashboard.value!.totalUsers,
                  totalPayments: ctrl.dashboard.value!.totalPayments,
                  balance: ctrl.dashboard.value!.totalExpense,
                  theme: theme,
                ),

                const SizedBox(height: 16),
                // ─── Wallet Summary ───────────────────
                WalletSummary(theme: theme, assistants: financeCtrl.assistants),

                const SizedBox(height: 16),
                // ─── Reports ──────────────────────────
                ReportsSummary(reports: ctrl.reports.value!, theme: theme),
                // ─── Recent Orders Carousel ───────────
                const SizedBox(height: 16),
                RecentOrdersList(
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

