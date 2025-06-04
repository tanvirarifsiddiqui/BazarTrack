import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:flutter_boilerplate/data/model/order/order_status.dart';

class OrderListScreen extends StatelessWidget {
  final OrderStatus? status;
  final String? assignedTo;
  const OrderListScreen({super.key, this.status, this.assignedTo});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (controller) {
      final orders = controller.getOrders(status: status, assignedTo: assignedTo);
      return Scaffold(
        appBar: AppBar(title: Text('orders'.tr)),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.createOrder,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (_, index) {
            final order = orders[index];
            return ListTile(
              title: Text(order.orderId),
              subtitle: Text(order.status.toString()),
              onTap: () => Get.toNamed(RouteHelper.getOrderDetailRoute(order.orderId)),
            );
          },
        ),
      );
    });
  }
}
