
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/dashboard/controller/analytics_controller.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../../orders/components/order_card.dart';

class RecentOrdersList extends StatelessWidget {

  const RecentOrdersList();

  @override
  Widget build(BuildContext context) {
    final AnalyticsController analyticsController = Get.find<AnalyticsController>();
    final orders = analyticsController.recentOrders;
    if (analyticsController.isLoadingRecent.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return const Center(child: Text('No recent orders.'));
    }

    // show only up to 5
    final recent = orders.take(5).toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Orders:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final order = recent[i];
                return OrderCard(order: order);
              },
            ),
          ],
        ),
      ),
    );
  }
}