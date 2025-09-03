import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../util/colors.dart';
import 'components/history_list.dart';
import 'controller/history_controller.dart';
class HistoryCenterPage extends StatelessWidget {
  const HistoryCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HistoryController>();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // No AppBar here — header is part of the page body for a more modern look
        body: SafeArea(
          child: Column(
            children: [
              // Stylish tab bar container
              Padding(
                padding:  EdgeInsets.fromLTRB(16.0, 12, 16, 0),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface, // subtle background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12), // ✅ reduces space
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Orders'),
                        Tab(text: 'Items'),
                        Tab(text: 'Payments'),
                      ],
                    )

                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    HistoryList(
                      loading: ctrl.isLoadingAll,
                      logs:    ctrl.allLogs,
                      loadingMore: ctrl.allLoadingMore,
                      hasMore:     ctrl.allHasMore,
                      onLoadMore:  ctrl.loadMoreAll,
                      onRefresh:   ctrl.refreshAll,
                    ),
                    HistoryList(
                      loading: ctrl.isLoadingOrder,
                      logs:    ctrl.orderLogs,
                      loadingMore: ctrl.orderLoadingMore,
                      hasMore:     ctrl.orderHasMore,
                      onLoadMore:  ctrl.loadMoreOrders,
                      onRefresh:   ctrl.refreshOrders,
                    ),
                    HistoryList(
                      loading: ctrl.isLoadingItem,
                      logs:    ctrl.itemLogs,
                      loadingMore: ctrl.itemLoadingMore,
                      hasMore:     ctrl.itemHasMore,
                      onLoadMore:  ctrl.loadMoreItems,
                      onRefresh:   ctrl.refreshItems,
                    ),
                    HistoryList(
                      loading: ctrl.isLoadingPayment,
                      logs:    ctrl.paymentLogs,
                      loadingMore: ctrl.paymentLoadingMore,
                      hasMore:     ctrl.paymentHasMore,
                      onLoadMore:  ctrl.loadMorePayments,
                      onRefresh:   ctrl.refreshPayments,
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),

      ),

    );

  }

}

