// File: lib/features/orders/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';

class OrderListScreen extends StatelessWidget {
  final OrderStatus? status;
  final String? assignedTo;
  const OrderListScreen({super.key, this.status, this.assignedTo});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (controller) {
      return FutureBuilder<List<Order>>(
        future: controller.getOrders(status: status, assignedTo: assignedTo),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          return Scaffold(
            appBar: AppBar(title: Text('orders'.tr)),
            floatingActionButton: FloatingActionButton(
              onPressed: controller.onCreateOrderTapped,
              child: const Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order.orderId ?? '-'),
                  subtitle: Text(order.status.toApi()),
                  onTap: () => Get.toNamed(
                      RouteHelper.getOrderDetailRoute(order.orderId!)),
                );
              },
            ),
          );
        },
      );
    });
  }
}