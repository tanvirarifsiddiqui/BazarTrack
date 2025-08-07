// lib/features/orders/screens/edit_order_item_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';

class EditOrderItemScreen extends StatefulWidget {
  final String orderId;
  final OrderItem item;

  const EditOrderItemScreen({
    super.key,
    required this.orderId,
    required this.item,
  });

  @override
  State<EditOrderItemScreen> createState() => _EditOrderItemScreenState();
}

class _EditOrderItemScreenState extends State<EditOrderItemScreen> {
  late TextEditingController _productCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _estCostCtrl;
  OrderItemStatus _status = OrderItemStatus.pending;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _productCtrl = TextEditingController(text: i.productName);
    _quantityCtrl = TextEditingController(text: i.quantity.toString());
    _unitCtrl = TextEditingController(text: i.unit);
    _estCostCtrl = TextEditingController(
      text: i.estimatedCost?.toString() ?? '',
    );
    _status = i.status;
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _estCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? 1;
    final est = double.tryParse(_estCostCtrl.text.trim());
    final updated = widget.item.copyWith(
      productName: _productCtrl.text.trim(),
      quantity: qty,
      unit: _unitCtrl.text.trim(),
      estimatedCost: est,
      status: _status,
    );

    try {
      await Get.find<OrderController>().updateOrderItem(updated);
      Get.back(result: updated);
    } catch (e) {
      Get.snackbar('Error', 'Could not update item: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _productCtrl,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _estCostCtrl,
              decoration:
              const InputDecoration(labelText: 'Estimated Cost'),
              keyboardType:
              TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<OrderItemStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: OrderItemStatus.values
                  .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.toApi()),
              ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _saving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: const Text('Save Item'),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
