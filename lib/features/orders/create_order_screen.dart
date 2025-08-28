import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/features/orders/components/draggable_info_head.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import '../../base/custom_button.dart';
import '../../base/custom_unit_dropdown.dart';
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
      // Use a Stack so we can show the draggable floating overlay above the page
      body: Stack(
        children: [
          Column(
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
                        btnColor: AppColors.tertiary,
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

          // Floating draggable total overlay
          Positioned.fill(
            child: SafeArea(
              child: IgnorePointer(
                ignoring: false,
                child: DraggableChatHead(ctrl: ctrl),
              ),
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
    final item = existing?.copyWith() ?? OrderItem.empty(orderId: 0);

    final productCtrl = TextEditingController(text: item.productName);
    final quantityCtrl = TextEditingController(text: item.quantity.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final estCtrl = TextEditingController(
      text: item.estimatedCost?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // Local mutable state & focus node for quantity input inside sheet
        int currentQty = int.tryParse(quantityCtrl.text.trim()) ?? item.quantity;
        const int minQuantity = 1; // require at least 1 for quantity
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

            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              _setQty(minQuantity);
                            },
                            icon: Icon(Icons.refresh, color: AppColors.primary),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.clear),
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textAlign: TextAlign.center,
                                decoration:
                                AppInputDecorations.generalInputDecoration(
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
                                    currentQty = parsed ?? minQuantity;
                                  });
                                },
                                validator: (v) {
                                  final parsed = int.tryParse(v?.trim() ?? '');
                                  if (parsed == null) return 'Enter quantity';
                                  if (parsed < minQuantity) {
                                    return 'Quantity must be at least $minQuantity';
                                  }
                                  return null;
                                },
                              ),

                              // A full-area GestureDetector that focuses the field when user taps outside the buttons
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
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    // color set from theme color constant
                                  ),
                                  color: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (currentQty > minQuantity) {
                                      _setQty(currentQty - 1);
                                    }
                                  },
                                ),
                              ),

                              // Increment button (right)
                              Positioned(
                                right: 4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      color: AppColors.primary,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            UnitDropdown(
                              value: unitCtrl.text.isEmpty ? null : unitCtrl.text,
                              onChanged: (val) {
                                unitCtrl.text = val ?? "";
                              },
                            ),
                            // Unit validation message (simple text under the dropdown)
                            Builder(builder: (ctx) {
                              // We'll validate on submit; show hint only
                              return const SizedBox(height: 0);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // For unit validation we will use a hidden FormField to attach a validator
                  FormField<String>(
                    initialValue: unitCtrl.text,
                    validator: (_) {
                      if (unitCtrl.text.trim().isEmpty) {
                        return 'Please select unit';
                      }
                      return null;
                    },
                    builder: (state) {
                      // Show error text if exists
                      return state.errorText == null
                          ? const SizedBox.shrink()
                          : Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
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
                            // Validate form (product, quantity, unit)
                            // Trigger the FormField validator for unit by calling formKey.currentState!.validate()
                            final isValid = formKey.currentState?.validate() ?? false;
                            // Additionally ensure unitCtrl validated (FormField above checks it)
                            if (!isValid) return;

                            // prefer typed value if present, otherwise currentQty
                            final qty =
                                int.tryParse(quantityCtrl.text.trim()) ?? currentQty;
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
              // calling method via new instance is okay here; keeps original call pattern
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
