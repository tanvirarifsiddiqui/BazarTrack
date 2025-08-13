// File: lib/features/orders/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/util/colors.dart';

import '../auth/model/role.dart';
import '../auth/service/auth_service.dart'; // Make sure this exists

class OrderListScreen extends StatelessWidget {
  final OrderStatus? status;
  final int? assignedTo;
  const OrderListScreen({super.key, this.status, this.assignedTo});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GetBuilder<OrderController>(
        builder: (controller) {
          return FutureBuilder<List<Order>>(
            future: controller.getOrders(
              status: status,
              assignedTo: assignedTo,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading orders'.tr));
              }

              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return Center(child: Text('No orders found.'.tr));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.update();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    final formattedDate = DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(order.createdAt.toLocal());

                    return Card(
                      elevation: 4,
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          child: SvgPicture.asset(
                            'assets/icons/order_icon.svg',
                            width: 24,
                            height: 24,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status.toApi().tr.capitalizeFirst!,
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'created_at'.trParams({'date': formattedDate}),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.icon,
                        ),
                        onTap:
                            () => Get.toNamed(
                              RouteHelper.getOrderDetailRoute(order.orderId!),
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Order'),
        icon: const Icon(Icons.add),
        onPressed: Get.find<OrderController>().onCreateOrderTapped,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
