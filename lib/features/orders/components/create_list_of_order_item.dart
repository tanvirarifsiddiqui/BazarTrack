import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../base/empty_state.dart';
import '../controller/order_controller.dart';
import 'create_order_item_card.dart';

class OrderItemsList extends StatelessWidget {
  final OrderController ctrl;
  const OrderItemsList({required this.ctrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.newItems;
      if (items.isEmpty) {
        return const EmptyState(
          icon: Icons.inventory,
          message: 'No items yet. Tap “Add Item” to begin.',
        );
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, idx) {
          return OrderItemCard(
            item: items[idx],
            onDelete: () => ctrl.removeItem(idx),
            onChanged: (it) => ctrl.newItems[idx] = it,
          );
        },
      );
    });
  }
}