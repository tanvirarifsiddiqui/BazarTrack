// lib/features/orders/screens/edit_order_item_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';

class EditOrderItemScreen extends StatefulWidget {
  /// Pass in a “blank” item (with id == null) to add,
  /// or an existing item (id != null) to edit.
  final String orderId;
  final OrderItem item;

  const EditOrderItemScreen({
    Key? key,
    required this.orderId,
    required this.item,
  }) : super(key: key);

  @override
  _EditOrderItemScreenState createState() => _EditOrderItemScreenState();
}

class _EditOrderItemScreenState extends State<EditOrderItemScreen> {
  late final TextEditingController _productCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _estCostCtrl;
  late OrderItemStatus _status;
  bool _saving = false;

  bool get _isNew => widget.item.id == null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _productCtrl   = TextEditingController(text: i.productName);
    _quantityCtrl  = TextEditingController(text: i.quantity.toString());
    _unitCtrl      = TextEditingController(text: i.unit);
    _estCostCtrl   =
        TextEditingController(text: i.estimatedCost?.toString() ?? '');
    _status        = i.status;
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

    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? widget.item.quantity;
    final est = double.tryParse(_estCostCtrl.text.trim());

    // Build a copy with new values
    final updated = widget.item.copyWith(
      orderId: _isNew ? int.parse(widget.orderId) : widget.item.orderId,
      productName:   _productCtrl.text.trim(),
      quantity:      qty,
      unit:          _unitCtrl.text.trim(),
      estimatedCost: est,
      status:        _status,
      // For new items, assign the correct orderId
      // orderId:       _isNew ? int.parse(widget.orderId) : widget.item.orderId,
    );

    try {
      if (_isNew) {
        // CREATE
        final created =
        await Get.find<OrderController>().createOrderItem(updated);
        Get.back(result: created);
      } else {
        // UPDATE
        await Get.find<OrderController>().updateOrderItem(updated);
        Get.back(result: updated);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save item: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Item' : 'Edit Item'),
        actions: [
          IconButton(onPressed: (){
            // Get.find<OrderController>().deleteOrderItem(widget.item);
          }, icon: Icon(Icons.delete, color: Colors.red,))
        ],
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
              decoration: const InputDecoration(labelText: 'Estimated Cost'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              label: Text(_isNew ? 'Add Item' : 'Save Item'),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
