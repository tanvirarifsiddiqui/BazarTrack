// lib/features/orders/screens/edit_order_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';

import '../auth/model/role.dart';
import '../auth/service/auth_service.dart';

class EditOrderItemScreen extends StatefulWidget {

  final String orderId;
  final OrderItem item;

  const EditOrderItemScreen({
    super.key,
    required this.orderId,
    required this.item,
  });

  @override
  _EditOrderItemScreenState createState() => _EditOrderItemScreenState();
}

class _EditOrderItemScreenState extends State<EditOrderItemScreen> {
  late final TextEditingController _productCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _estCostCtrl;
  late final TextEditingController _actualCostCtrl;
  late OrderItemStatus _status;

  final OrderController _controller = Get.find<OrderController>();
  bool _saving = false;
  bool _isPurchased = false;
  bool get _isNew => widget.item.id == null;

  @override
  void initState() {
    super.initState();
    final orderItem = widget.item;
    _isPurchased = orderItem.status == OrderItemStatus.purchased;
    _productCtrl   = TextEditingController(text: orderItem.productName);
    _quantityCtrl  = TextEditingController(text: orderItem.quantity.toString());
    _unitCtrl      = TextEditingController(text: orderItem.unit);
    _estCostCtrl   = TextEditingController(text: orderItem.estimatedCost?.toString() ?? '');
    _actualCostCtrl  = TextEditingController(text: orderItem.actualCost?.toString() ?? '');
    _status        = orderItem.status;
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _estCostCtrl.dispose();
    _actualCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? widget.item.quantity;
    final est = double.tryParse(_estCostCtrl.text.trim());
    final actualCost = double.tryParse(_actualCostCtrl.text.trim());

    // Build a copy with new values
    final updated = widget.item.copyWith(
      orderId: _isNew ? int.parse(widget.orderId) : widget.item.orderId,
      productName:   _productCtrl.text.trim(),
      quantity:      qty,
      unit:          _unitCtrl.text.trim(),
      estimatedCost: est,
      actualCost: actualCost,
      status:        _status,
      // For new items, assign the correct orderId
      // orderId:       _isNew ? int.parse(widget.orderId) : widget.item.orderId,
    );

    try {
      if (_isNew) {
        // CREATE
        final created =
        await _controller.createOrderItem(updated);
        Get.back(result: created);
      } else {
        // UPDATE
        await _controller.updateOrderItem(updated, _isPurchased);
        Get.back(result: updated);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save item: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Item?'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _controller.deleteOrderItem(widget.item);
      Get.back(); // pop the edit screen
      Get.snackbar('Deleted', 'Item has been removed', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final isAssistant = auth.currentUser?.role == UserRole.assistant;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isNew ? 'Add Item' : 'Edit Item',
        actions: [
          if(!_isNew)IconButton(onPressed: (){
            _confirmAndDelete();
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
            if(isAssistant && !_isPurchased)...[
              TextFormField(
                controller: _actualCostCtrl,
                decoration: const InputDecoration(labelText: 'Actual Cost'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
            ],
            if(!_isPurchased)DropdownButtonFormField<OrderItemStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: OrderItemStatus.values
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.toApi()),
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
