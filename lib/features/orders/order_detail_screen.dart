// File: lib/features/orders/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';

import '../../util/dimensions.dart';
import 'edit_order_item_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();
    final auth = Get.find<AuthService>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    final isAssistant = auth.currentUser?.role == UserRole.assistant;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order #$orderId',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Audit Trail',
            onPressed: () {
              Get.toNamed(RouteHelper.getHistoryRoute('Order', orderId));
            },
          ),
        ],
      ),
      body: GetBuilder<OrderController>(
        builder: (_) {
          final order = orderCtrl.getOrder(orderId);
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ORDER INFO CARD
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Created by',
                          order.createdBy.toString(),
                          Icons.person,
                        ),
                        _buildInfoRow(
                          'Assigned to',
                          order.assignedTo ?? 'Unassigned',
                          Icons.group,
                        ),
                        _buildInfoRow(
                          'Status',
                          order.status.toApi(),
                          Icons.flag,
                        ),
                        _buildInfoRow(
                          'Created at',
                          dateFmt.format(order.createdAt),
                          Icons.schedule,
                        ),
                        _buildInfoRow(
                          'Completed at',
                          order.completedAt != null
                              ? dateFmt.format(order.completedAt!)
                              : '-',
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ),
                ),

                // ITEMS LIST via FutureBuilder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (isOwner)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                        onPressed: () async {
                          final newItem = OrderItem.empty(
                            orderId: int.parse(orderId),
                          );
                          final created = await Get.to<OrderItem>(
                            () => EditOrderItemScreen(
                              orderId: orderId,
                              item: newItem,
                            ),
                          );
                          if (created != null) {
                            orderCtrl.loadItems(orderId);
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<OrderItem>>(
                  future: orderCtrl.getItemsOfOrder(orderId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading items: ${snapshot.error}'),
                      );
                    }
                    final items = snapshot.data!;
                    if (items.isEmpty) {
                      return const Center(child: Text('No items added yet.'));
                    }
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, idx) {
                        final item = items[idx];
                        return ListTile(
                          leading: const Icon(Icons.shopping_basket),
                          title: Text(item.productName),
                          subtitle: Text(
                            '${item.quantity} ${item.unit} • ${item.status.toApi()}',
                          ),
                          trailing:
                              item.estimatedCost != null
                                  ? Text(
                                    NumberFormat.currency(
                                      // locale: 'bn_BD', // Bangla Bangladesh locale
                                      symbol: '৳', // Taka symbol
                                    ).format(item.estimatedCost),
                                    style: TextStyle(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                          onTap: () async {
                            final updated = await Get.to<OrderItem>(
                              () => EditOrderItemScreen(
                                orderId: orderId,
                                item: item,
                              ),
                            );
                            if (updated != null) {
                              // trigger reload by rebuilding
                              orderCtrl.update();
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ACTION BUTTONS
                Row(
                  children: [
                    if (!isOwner && order.assignedTo == null)
                      if (isAssistant)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Assign to me'),
                            onPressed: () {
                              orderCtrl.selfAssign(orderId);
                            },
                          ),
                        ),

                    if (isOwner) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('Assign User'),
                          onPressed: () async {
                            final userId = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                final sample = ['2', '3', '4'];
                                return SimpleDialog(
                                  title: const Text('Select User'),
                                  children:
                                      sample
                                          .map(
                                            (u) => SimpleDialogOption(
                                              child: Text('User #$u'),
                                              onPressed:
                                                  () => Navigator.pop(ctx, u),
                                            ),
                                          )
                                          .toList(),
                                );
                              },
                            );
                            if (userId != null) {
                              orderCtrl.assignOrder(orderId, userId);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    if (isAssistant)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.done_all),
                          label: Text(
                            order.status == OrderStatus.completed
                                ? 'Completed'
                                : 'Mark Complete',
                          ),
                          onPressed:
                              order.status == OrderStatus.completed
                                  ? null
                                  : () {
                                    orderCtrl.completeOrder(orderId);
                                  },
                        ),
                      ),
                    if (isOwner)
                      Expanded(
                        child: Text(
                          order.status == OrderStatus.completed
                              ? 'Completed'
                              : 'In Progress', // or any status text you prefer
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                order.status == OrderStatus.completed
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
