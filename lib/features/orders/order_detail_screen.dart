// File: lib/features/orders/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ORDER INFO CARD
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Created by', order.createdBy.toString(), Icons.person),
                        _buildInfoRow('Assigned to', order.assignedTo.toString(), Icons.group),
                        _buildInfoRow('Status', order.status.toApi(), Icons.flag),
                        _buildInfoRow('Created at', dateFmt.format(order.createdAt), Icons.schedule),
                        _buildInfoRow(
                          'Completed at',
                          order.completedAt != null ? dateFmt.format(order.completedAt!) : '-',
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ),
                ),

                // ITEMS HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Items',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      if(isOwner)CustomButton(
                          icon: Icons.add,
                          height: 35,
                          width: 100,
                          buttonText: 'Add Item',
                          onPressed: () async {
                            final newItem = OrderItem.empty(orderId: int.parse(orderId));
                            final created = await Get.to<OrderItem>(
                                  () => EditOrderItemScreen(orderId: orderId, item: newItem),
                            );
                            if (created != null) {
                              orderCtrl.loadItems(orderId);
                            }
                          },
                        ),
                    ],
                  ),
                ),

                // SCROLLABLE ITEMS LIST ONLY
                Expanded(
                  child: FutureBuilder<List<OrderItem>>(
                    future: orderCtrl.getItemsOfOrder(orderId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading items: ${snapshot.error}'));
                      }

                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return const Center(child: Text('No items added yet.'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
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
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.estimatedCost != null)
                                  Text(
                                    'Est: ${NumberFormat.currency(symbol: '৳').format(item.estimatedCost)}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                if (item.actualCost != null)
                                  Text(
                                    'Act: ${NumberFormat.currency(symbol: '৳').format(item.actualCost)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              final updated = await Get.to<OrderItem>(
                                    () => EditOrderItemScreen(orderId: orderId, item: item),
                              );
                              if (updated != null) {
                                orderCtrl.update();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // ACTION BUTTONS
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      if (!isOwner && order.assignedTo == null && isAssistant)
                        Expanded(
                          child: CustomButton(
                            icon: Icons.person_add,
                            width: MediaQuery.of(context).size.width * .45,
                            buttonText: 'Assign to me',
                            onPressed: () {
                              try{
                                orderCtrl.selfAssign(orderId);
                              }catch(e){
                                Get.snackbar('Error', 'Could not Self Assign: $e');
                              }
                            },
                          ),
                        ),

                      if (isOwner) ...[
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Assign User',
                            icon: Icons.person,
                            onPressed: () async {
                              final userId = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  final sample = ['2', '3', '4'];
                                  return SimpleDialog(
                                    title: const Text('Select User'),
                                    children: sample
                                        .map((u) => SimpleDialogOption(
                                      child: Text('User #$u'),
                                      onPressed: () => Navigator.pop(ctx, u),
                                    ))
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
                          child: CustomButton(
                            icon: Icons.done_all,
                            buttonText:
                              order.status == OrderStatus.completed
                                  ? 'Completed'
                                  : 'Mark Complete',

                            onPressed: order.status == OrderStatus.completed
                                ? null
                                : () => orderCtrl.completeOrder(orderId),
                          ),
                        ),

                      if (isOwner)
                        Expanded(
                          child: Text(
                            order.status == OrderStatus.completed
                                ? 'Completed'
                                : 'In Progress',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: order.status == OrderStatus.completed
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
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
