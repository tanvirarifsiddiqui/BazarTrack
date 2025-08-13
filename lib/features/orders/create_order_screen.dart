// lib/features/orders/presentation/create_order_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';

import '../../util/finance_input_decoration.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    int? selectedId;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
      ),
      body: GetBuilder<OrderController>(
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) Assigned To
              DropdownButtonFormField<int>(
                borderRadius: BorderRadius.circular(12),
                value: selectedId,
                items:
                [DropdownMenuItem(
                    value: null,
                      child: Text("None")
                  )
                ,...ctrl.assistants
                    .map(
                      (a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name),
                  ),
                )
                    .toList(),],
                onChanged: (v) => ctrl.assignedToUserId = v ?? selectedId,
                decoration: AppInputDecorations.financeInputDecoration(
                  label: 'Select Assistant',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 16),

              // 2) Items list
              Expanded(
                child: ctrl.newItems.isEmpty
                    ? Center(child: Text('No items yet'))
                    : ListView.separated(
                  itemCount: ctrl.newItems.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey),
                  itemBuilder: (_, idx) {
                    final item = ctrl.newItems[idx];
                    return _OrderItemTile(
                      item: item,
                      onDelete: () => ctrl.removeItem(idx),
                      onChanged: (updated) {
                        ctrl.newItems[idx] = updated;
                        ctrl.update();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 3) Add Item & Save buttons side by side
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Add Item'),
                      onPressed: ctrl.addItem,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save Order'),
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
                  Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),

              // Product name
              TextFormField(
                initialValue: item.productName,
                decoration: InputDecoration(labelText: 'Product Name'),
                onChanged: (v) => onChanged(item.copyWith(productName: v)),
              ),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: item.quantity.toString(),
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final q = int.tryParse(v) ?? item.quantity;
                        onChanged(item.copyWith(quantity: q));
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: item.unit,
                      decoration: InputDecoration(labelText: 'Unit'),
                      onChanged: (v) => onChanged(item.copyWith(unit: v)),
                    ),
                  ),
                ],
              ),

              // Estimated cost
              TextFormField(
                initialValue: item.estimatedCost?.toString() ?? '',
                decoration: InputDecoration(labelText: 'Estimated Cost'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
