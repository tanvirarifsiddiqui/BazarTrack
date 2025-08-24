import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const CreateOrderScreen({super.key});

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
        existing?.copyWith() ?? OrderItem.empty(orderId: 0); // you’ll set real orderId later

    final productCtrl = TextEditingController(text: item.productName);
    final quantityCtrl = TextEditingController(text: item.quantity.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final estCtrl = TextEditingController(
      text: item.estimatedCost?.toString() ?? '',
    );

    return showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // Local mutable state & focus node for quantity input inside sheet
        int currentQty = int.tryParse(quantityCtrl.text.trim()) ?? item.quantity;
        const int minQuantity = 0; // change to 1 if you want a minimum of 1
        final qtyFocus = FocusNode();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            void _setQty(int newQty) {
              final safe = newQty < minQuantity ? minQuantity : newQty;
              setState(() {
                currentQty = safe;
                quantityCtrl.text = currentQty.toString();
                quantityCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: quantityCtrl.text.length),
                );
              });
            }

            return Column(
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
                            _setQty(0);
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

                // Quantity (floating +/- over TextField) & Unit
                Row(
                  children: [
                    // Quantity area (will take available width defined by flex)
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // The actual TextField (fills area)
                            TextFormField(
                              controller: quantityCtrl,
                              focusNode: qtyFocus,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textAlign: TextAlign.center,
                              decoration: AppInputDecorations.generalInputDecoration(
                                label: 'Quantity',
                              ).copyWith(
                                // leave horizontal padding so text doesn't touch floating buttons
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 42,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val.trim());
                                setState(() {
                                  currentQty = parsed ?? 0;
                                });
                              },
                            ),

                            // A full-area GestureDetector that focuses the field when user taps outside the buttons
                            // (Placed before buttons so buttons are on top and remain tappable.)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  qtyFocus.requestFocus();
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),

                            // Decrement button (left)
                            Positioned(
                              left: 4,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary,),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  if (currentQty > minQuantity) _setQty(currentQty - 1);
                                },
                              ),
                            ),

                            // Increment button + small "Here" focus button (right)
                            Positioned(
                              right: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary,),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _setQty(currentQty + 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Unit input
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
                          // prefer typed value if present, otherwise currentQty
                          final qty = int.tryParse(quantityCtrl.text.trim()) ?? currentQty;
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
            );
          }),
        );
      },
    );
  }



}

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
