import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../helper/route_helper.dart';
import '../../../util/colors.dart';
import '../../../util/dimensions.dart';

class OrderCard extends StatelessWidget {
  final order;
  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a')
        .format(order.createdAt.toLocal());
    final theme = Theme.of(context);
    final statusLabel = order.status.toString().split('.').last.capitalizeFirst!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
      ),
      color: AppColors.cardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.receipt_long, color: AppColors.primary),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              statusLabel,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Created at $date',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Get.toNamed(
          RouteHelper.getOrderDetailRoute(order.orderId!),
        ),
      ),
    );
  }
}