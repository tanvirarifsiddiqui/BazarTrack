
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:get/get.dart';
import '../../../base/empty_state.dart';
import '../../../util/dimensions.dart';
import '../../orders/components/order_card.dart';

class RecentOrdersList<T> extends StatelessWidget {
  final RxList<T> recentOrders;
  final RxBool isLoadingRecent;
  final bool isOwner;


  const RecentOrdersList({
    super.key,
    required this.recentOrders,
    required this.isLoadingRecent,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoadingRecent.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
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
                Text(isOwner?'Recently Created Orders' : 'Recently Assigned Orders', style: Theme.of(context).textTheme.titleLarge),
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
    });
  }
}

