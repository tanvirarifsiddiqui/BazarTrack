import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/util/app_format.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import '../../base/empty_state.dart';
import '../../base/price_format.dart';
import '../finance/model/assistant.dart';
import 'components/edit_order_item_bottomsheet.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderController orderCtrl;
  late final AuthController authCtrl;
  Future<Order?>? _orderFuture;
  Future<List<OrderItem>>? _itemsFuture;

  @override
  void initState() {
    super.initState();
    orderCtrl = Get.find<OrderController>();
    authCtrl = Get.find<AuthController>();
    _loadAll();
  }

  void _loadAll() {
    _orderFuture = orderCtrl.getOrder(widget.orderId);
    _itemsFuture = orderCtrl.getItemsOfOrder(widget.orderId);
    // call setState to ensure builders run when init completes
    setState(() {});
  }

  Future<void> _reloadOrder() async {
    setState(() {
      _orderFuture = orderCtrl.getOrder(widget.orderId);
    });
  }

  Future<void> _reloadItems() async {
    setState(() {
      _itemsFuture = orderCtrl.getItemsOfOrder(widget.orderId);
    });
  }

  Future<void> _onAddItem() async {
    final newItem = OrderItem.empty(orderId: int.parse(widget.orderId));
    final created = await showModalBottomSheet<OrderItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final keyboardBottomSize = MediaQuery.of(ctx).viewInsets.bottom;
        final initialHeight = 400.0;
        final bigHeight = MediaQuery.of(ctx).size.height * 0.80;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: keyboardBottomSize > 0 ? bigHeight : initialHeight,
          child: EditOrderItemBottomSheet(
            orderId: widget.orderId,
            item: newItem,
            autoFocusFirstField: true, // important: will request focus
          ),
        );
      },
    );

    if (created != null) {
      orderCtrl.loadItems(widget.orderId);
      await _reloadItems();
    }
  }

  Future<void> _onEditItem(OrderItem item) async {
    final updated = await showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        final initialHeight = 400.0;
        final bigHeight = MediaQuery.of(ctx).size.height * 0.80;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: kb > 0 ? bigHeight : initialHeight,
          child: EditOrderItemBottomSheet(orderId: widget.orderId, item: item, autoFocusFirstField: true, ),
        );
      },
    );

    if (updated != null) {
      orderCtrl.loadItems(widget.orderId);
      await _reloadItems();
      await _reloadOrder();
    }
  }

  //
  // Future<void> _onEditItem(OrderItem item) async {
  //   final updated = await Get.to<OrderItem>(
  //     () => EditOrderItemScreen(orderId: widget.orderId, item: item),
  //   );
  //   if (updated != null) {
  //     // controller may have to reload items
  //     orderCtrl.loadItems(widget.orderId);
  //     await _reloadItems();
  //     await _reloadOrder(); // in case costs/status changed
  //   }
  // }

  Future<void> _onAssignUser(BuildContext context) async {
    try {
      final int? selectedAssistantId = await showDialog<int?>(
        context: context,
        builder: (ctx) {
          return FutureBuilder<List<Assistant>>(
            future: orderCtrl.getAllAssistantsWithCurrentBalance(),
            builder: (ctx2, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SimpleDialog(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Loading assistants...'),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return SimpleDialog(
                  title: const Text('Select Assistant'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Error loading assistants: ${snapshot.error}',
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, null),
                      child: const Text('Close'),
                    ),
                  ],
                );
              }

              final assistants = snapshot.data ?? [];

              return SimpleDialog(
                title: const Text('Select Assistant'),
                children: [
                  if (assistants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('No assistants available.'),
                    )
                  else
                    ...assistants.map((assistant) {
                      return SimpleDialogOption(
                        onPressed: () => Navigator.pop(ctx, assistant.id),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                assistant.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '৳ ${assistant.balance?.toString() ?? '0'}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      );

      if (selectedAssistantId != null) {
        await orderCtrl.assignOrder(widget.orderId, selectedAssistantId);
        await _reloadOrder();
        Get.snackbar('Success', 'Assistant assigned');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not assign assistant: $e');
    }
  }

  Future<void> _onSelfAssign() async {
    try {
      await orderCtrl.selfAssign(widget.orderId);
      await _reloadOrder();
      Get.snackbar('Success', 'Assigned to you');
    } catch (e) {
      Get.snackbar('Error', 'Could not self-assign: $e');
    }
  }

  Future<void> _onCompleteOrder() async {
    try {
      await orderCtrl.completeOrder(widget.orderId);
      await _reloadOrder();
      Get.snackbar('Success', 'Order marked completed');
    } catch (e) {
      Get.snackbar('Error', 'Could not complete order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = authCtrl.user.value?.role == UserRole.owner;
    final isAssistant = authCtrl.user.value?.role == UserRole.assistant;
    final dateFmt = AppFormats.appDateTimeFormat;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order #${widget.orderId}',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Audit Trail',
            onPressed: () {
              Get.toNamed(
                RouteHelper.getEntityHistoryRoute('Order', widget.orderId),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Order?>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading order: ${snapshot.error}'),
              );
            }

            final order = snapshot.data;
            if (order == null) {
              return const Center(child: Text('Order not found'));
            }

            return Padding(
              padding: const EdgeInsets.all(Dimensions.scaffoldIndependent),
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Table(
                            columnWidths: const {
                              0: FixedColumnWidth(40), // icon column
                              1: IntrinsicColumnWidth(), // label column
                              2: FlexColumnWidth(), // value column
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            children: [
                              _buildTableRow(
                                Icons.person,
                                'Created by',
                                order.createdUserName.toString(),
                              ),
                              _buildTableRow(
                                Icons.group,
                                'Assigned to',
                                order.assignedUserName?.toString() ?? '-',
                              ),
                              _buildTableRow(
                                Icons.flag,
                                'Status',
                                order.status.toApi(),
                              ),
                              _buildTableRow(
                                Icons.schedule,
                                'Created at',
                                dateFmt.format(order.createdAt),
                              ),
                              _buildTableRow(
                                Icons.check_circle,
                                'Completed at',
                                order.completedAt != null
                                    ? dateFmt.format(order.completedAt!)
                                    : '-',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ITEMS HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Items',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        if (isOwner)
                          CustomButton(
                            icon: Icons.add,
                            height: 35,
                            width: 100,
                            buttonText: 'Add Item',
                            onPressed: _onAddItem,
                          ),
                      ],
                    ),
                  ),

                  // SCROLLABLE ITEMS LIST ONLY
                  Expanded(
                    child: FutureBuilder<List<OrderItem>>(
                      future: _itemsFuture,
                      builder: (context, itemSnap) {
                        if (itemSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (itemSnap.hasError) {
                          return Center(
                            child: Text(
                              'Error loading items: ${itemSnap.error}',
                            ),
                          );
                        }

                        final items = itemSnap.data ?? [];
                        if (items.isEmpty) {
                          return const EmptyState(
                            icon: Icons.inventory,
                            message: 'No items added yet. Tap “Add Item” to begin.',
                          );
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
                                      'Est: ${formatPrice(item.estimatedCost)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (item.actualCost != null)
                                    Text(
                                      'Act: ${formatPrice(item.actualCost)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => _onEditItem(item),
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
                         ...[ Expanded(
                            child: CustomButton(
                              icon: Icons.person_add,
                              buttonText: 'Assign to me',
                              onPressed: _onSelfAssign,
                              btnColor: AppColors.tertiary,
                            ),
                          ),
                           const SizedBox(width: 12),
                         ],

                        if (isOwner) ...[
                          Expanded(
                            child: CustomButton(
                              buttonText: 'Assign User',
                              icon: Icons.person,
                              onPressed: () => _onAssignUser(context),
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
                              onPressed:
                                  order.status == OrderStatus.completed
                                      ? null
                                      : _onCompleteOrder,
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
                                color:
                                    order.status == OrderStatus.completed
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
      ),
    );
  }

  TableRow _buildTableRow(IconData icon, String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(padding: const EdgeInsets.all(4), child: Text(": $value")),
      ],
    );
  }
}
