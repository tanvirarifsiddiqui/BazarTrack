import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import '../../util/input_decoration.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'New Order'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) Assistant dropdown
              Obx(() => DropdownButtonFormField<int?>(
                borderRadius: BorderRadius.circular(12),
                value: ctrl.assignedToUserId.value,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text("None")),
                  ...ctrl.assistants
                      .map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name),
                  ))
                      .toList(),
                ],
                onChanged: (v) => ctrl.assignedToUserId.value = v,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Select Assistant',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              )),

              const SizedBox(height: 16),

              // 2) Items list
              Expanded(
                child: Obx(() => ctrl.newItems.isEmpty
                    ? const Center(child: Text('No items yet'))
                    : ListView.separated(
                  itemCount: ctrl.newItems.length,
                  separatorBuilder: (_, __) =>
                  const Divider(color: Colors.grey),
                  itemBuilder: (_, idx) {
                    final item = ctrl.newItems[idx];
                    return _OrderItemTile(
                      item: item,
                      onDelete: () => ctrl.removeItem(idx),
                      onChanged: (updated) {
                        ctrl.newItems[idx] = updated;
                      },
                    );
                  },
                )),
              ),

              const SizedBox(height: 16),

              // 3) Add Item & Save
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.add,
                      buttonText: 'Add Item',
                      onPressed: ctrl.addItem,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.save,
                      buttonText: 'Save Order',
                      onPressed: ctrl.saveNewOrder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final void Function(OrderItem) onChanged;
  final VoidCallback onDelete;

  const _OrderItemTile({
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Item',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),

              // Product name
              TextFormField(
                initialValue: item.productName,
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (v) => onChanged(item.copyWith(productName: v)),
              ),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: item.quantity.toString(),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final q = int.tryParse(v) ?? item.quantity;
                        onChanged(item.copyWith(quantity: q));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: item.unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      onChanged: (v) => onChanged(item.copyWith(unit: v)),
                    ),
                  ),
                ],
              ),

              // Estimated cost
              TextFormField(
                initialValue: item.estimatedCost?.toString() ?? '',
                decoration:
                const InputDecoration(labelText: 'Estimated Cost'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final d = double.tryParse(v);
                  onChanged(item.copyWith(estimatedCost: d));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
