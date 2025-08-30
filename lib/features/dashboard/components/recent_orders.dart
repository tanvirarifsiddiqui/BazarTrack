
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/empty_state.dart';
import '../../../util/dimensions.dart';
import '../../orders/components/order_card.dart';

class RecentOrdersList<T> extends StatelessWidget {
  final RxList<T> recentOrders;
  final RxBool isLoadingRecent;

  const RecentOrdersList({
    Key? key,
    required this.recentOrders,
    required this.isLoadingRecent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoadingRecent.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (recentOrders.isEmpty) {
        return EmptyState(
          icon: Icons.inbox,
          message: 'No recent orders.',
        );
    }

    final recent = recentOrders.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
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
                  return OrderCard(order: order); // order type T must be compatible with OrderCard
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
