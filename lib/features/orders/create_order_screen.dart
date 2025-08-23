import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import '../../base/custom_button.dart';
import '../../base/empty_state.dart';
import '../../util/input_decoration.dart';
import 'components/assistant_selector.dart';
import 'components/create_order_item_card.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(title: 'New Order'),
      body: Column(
        children: [
          // 1) ASSISTANT SELECTOR (unchanged)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AssistantSelector(ctrl: ctrl),
          ),

          // 2) ITEMS LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OrderItemsList(ctrl: ctrl),
            ),
          ),

          // 3) ACTIONS: ADD ITEM & SAVE ORDER
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icons.add,
                    buttonText: 'Add Item',
                    onPressed: () async {
                      final newItem = await _showItemDialog(context);
                      if (newItem != null) {
                        ctrl.newItems.add(newItem);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final hasItems = ctrl.newItems.isNotEmpty;
                    return CustomButton(
                      icon: Icons.save,
                      buttonText: 'Save Order',
                      onPressed: hasItems ? ctrl.saveNewOrder : null,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<OrderItem?> _showItemDialog(
    BuildContext context, [
    OrderItem? existing,
  ]) {
    final isNew = existing == null;
    final item =
        existing?.copyWith() ??
        OrderItem.empty(orderId: 0); // you’ll set real orderId later

    final productCtrl = TextEditingController(text: item.productName);
    final quantityCtrl = TextEditingController(text: item.quantity.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final estCtrl = TextEditingController(
      text: item.estimatedCost?.toString() ?? '',
    );

    return showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isNew ? 'Add New Item' : 'Edit Item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          productCtrl.clear();
                          quantityCtrl.clear();
                          unitCtrl.clear();
                          estCtrl.clear();
                        },
                        icon: Icon(Icons.refresh, color: AppColors.primary),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.clear),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Name
              TextFormField(
                controller: productCtrl,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Product Name',
                  prefixIcon: Icons.shopping_basket,
                ),
              ),
              const SizedBox(height: 12),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'Quantity',
                        prefixIcon: Icons.confirmation_number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: unitCtrl,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'Unit',
                        prefixIcon: Icons.straighten,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Estimated Cost
              TextFormField(
                controller: estCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Estimated Cost',
                  prefixText: '৳ ',
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [

                  Expanded(
                    child: CustomButton(
                      buttonText: isNew ? 'Add item to Order' : 'Save',
                      icon: isNew ? Icons.add : Icons.check,
                      onPressed: () {
                        final qty =
                            int.tryParse(quantityCtrl.text.trim()) ??
                            item.quantity;
                        final est = double.tryParse(estCtrl.text.trim());
                        final updated = item.copyWith(
                          productName: productCtrl.text.trim(),
                          quantity: qty,
                          unit: unitCtrl.text.trim(),
                          estimatedCost: est,
                        );
                        Navigator.pop(context, updated);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class OrderItemsList extends StatelessWidget {
  final OrderController ctrl;
  const OrderItemsList({required this.ctrl, Key? key}) : super(key: key);

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
            onEdit: () async {
              final updated = await CreateOrderScreen()._showItemDialog(
                context,
                items[idx],
              );
              if (updated != null) {
                ctrl.newItems[idx] = updated;
              }
            },
          );
        },
      );
    });
  }
}
