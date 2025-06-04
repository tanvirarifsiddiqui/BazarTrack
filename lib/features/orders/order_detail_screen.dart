import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (controller) {
      final order = controller.getOrder(orderId);
      if (order == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Order Detail')),
          body: const Center(child: Text('Order not found')),
        );
      }

      final auth = Get.find<AuthController>();
      return Scaffold(
        appBar: AppBar(title: Text('Order ${order.orderId}')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Created by: ${order.createdBy}'),
              Text('Assigned to: ${order.assignedTo ?? 'Unassigned'}'),
              Text('Status: ${order.status}'),
              Text('Created at: ${order.createdAt}'),
              Text('Completed at: ${order.completedAt ?? '-'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (auth.isOwner) {
                    controller.assignOrder(order.orderId, auth.currentUser!.id);
                  } else {
                    controller.selfAssign(order.orderId);
                  }
                },
                child: Text(order.assignedTo == null ? 'Assign to me' : 'Reassign'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(RouteHelper.getHistoryRoute('Order', order.orderId)),
                child: Text('view_history'.tr),
              ),
            ],
          ),
        ),
      );
    });
  }
}
