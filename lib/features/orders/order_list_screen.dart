// lib/features/orders/screens/order_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import '../../util/finance_input_decoration.dart';
import '../auth/model/role.dart';
import '../auth/service/auth_service.dart';

class OrderListScreen extends StatelessWidget {
  final OrderStatus? initialStatus;
  final int?         initialAssignedTo;

  const OrderListScreen({
    Key? key,
    this.initialStatus,
    this.initialAssignedTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth   = Get.find<AuthService>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    final ctrl   = Get.find<OrderController>();

    // apply any initial filters once
    if (initialStatus != null) {
      ctrl.setStatusFilter(initialStatus);
    }
    if (initialAssignedTo != null) {
      ctrl.setAssignedToFilter(initialAssignedTo);
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          // ─── Filter Bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,8),
            child: Row(
              children: [
                // Status Filter
                Expanded(
                  child: Obx(() {
                    return DropdownButtonFormField<OrderStatus?>(
                      borderRadius: BorderRadius.circular(12),
                      value: ctrl.filterStatus.value,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'Status',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All'),
                        ),
                        ...OrderStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.toApi().tr.capitalizeFirst!),
                          );
                        })
                      ],
                      onChanged: ctrl.setStatusFilter,
                    );
                  }),
                ),

                const SizedBox(width: 12),

                // Assigned To Filter (unassigned vs owned by me)
                if (isOwner)
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<int?>(
                        borderRadius: BorderRadius.circular(12),
                        value: ctrl.filterAssignedTo.value,
                        decoration: AppInputDecorations.generalInputDecoration(
                          label: 'Assigned to',
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text('All')),
                          ...ctrl.assistants
                              .map(
                                (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            ),
                          )
                        ],
                        onChanged: ctrl.setAssignedToFilter,

                      );
                    }),
                  ),
              ],
            ),
          ),

          // ─── Order List ────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = ctrl.orders;
              if (list.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              return RefreshIndicator(
                onRefresh: ctrl.loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, idx) {
                    final order = list[idx];
                    final date  = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(order.createdAt.toLocal());

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppColors.cardBackground,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor:
                          AppColors.primary.withValues(alpha: 0.2),
                          child: SvgPicture.asset(
                            'assets/icons/order_icon.svg',
                            width: 20, height: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status.toApi().tr.capitalizeFirst!,
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'created_at'.trParams({'date': date}),
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                        onTap: () => Get.toNamed(
                          RouteHelper.getOrderDetailRoute(order.orderId!),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      // ─── Create Order FAB ───────────────────────────────
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
        heroTag: 'add_order',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Order'),
        onPressed: ctrl.onCreateOrderTapped,
      )
          : null,
    );
  }
}
