import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import '../../util/input_decoration.dart';
import '../../helper/route_helper.dart';
import '../auth/model/role.dart';
import 'controller/order_controller.dart';
import 'model/order_item.dart';

class EditOrderItemScreen extends StatefulWidget {
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
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _productCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _estCostCtrl;
  late final TextEditingController _actualCostCtrl;

  // Focus nodes
  final _productFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _unitFocus = FocusNode();
  final _estCostFocus = FocusNode();
  final _actualCostFocus = FocusNode();

  // State
  late OrderItemStatus _status;
  late bool _isPurchased;
  bool _saving = false;

  bool get _isNew => widget.item.id == null;

  final _controller = Get.find<OrderController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final itm = widget.item;
    _isPurchased   = itm.status == OrderItemStatus.purchased;
    _status        = itm.status;
    _productCtrl   = TextEditingController(text: itm.productName);
    _quantityCtrl  = TextEditingController(text: itm.quantity.toString());
    _unitCtrl      = TextEditingController(text: itm.unit);
    _estCostCtrl   = TextEditingController(text: itm.estimatedCost?.toString() ?? '');
    _actualCostCtrl= TextEditingController(text: itm.actualCost?.toString() ?? '');
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _estCostCtrl.dispose();
    _actualCostCtrl.dispose();
    _productFocus.dispose();
    _quantityFocus.dispose();
    _unitFocus.dispose();
    _estCostFocus.dispose();
    _actualCostFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final qty    = int.tryParse(_quantityCtrl.text.trim()) ?? widget.item.quantity;
    final est    = double.tryParse(_estCostCtrl.text.trim());
    final actual = double.tryParse(_actualCostCtrl.text.trim());

    final updated = widget.item.copyWith(
      orderId:      int.parse(widget.orderId),
      productName:  _productCtrl.text.trim(),
      quantity:     qty,
      unit:         _unitCtrl.text.trim(),
      estimatedCost: est,
      actualCost:    actual,
      status:        _status,
    );

    try {
      if (_isNew) {
        final created = await _controller.createOrderItem(updated);
        Get.back(result: created);
      } else {
        await _controller.updateOrderItem(updated, _isPurchased);
        Get.back(result: updated);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save item: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _controller.deleteOrderItem(widget.item);
      Get.back(); // pop edit screen
      Get.snackbar('Deleted', 'Item removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAssistant = _authController.user.value?.role == UserRole.assistant;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isNew ? 'Add Item' : 'Edit Item',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Audit Trail',
            onPressed: () {
              Get.toNamed(
                RouteHelper.getEntityHistoryRoute(
                  'Order_item', widget.item.id.toString(),
                ),
              );
            },
          ),
          if (!_isNew && !_isPurchased)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Item',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PRODUCT NAME
                TextFormField(
                  controller: _productCtrl,
                  focusNode: _productFocus,
                  textInputAction: TextInputAction.next,
                  decoration: AppInputDecorations.generalInputDecoration(
                    label: 'Product Name',
                    prefixIcon: Icons.shopping_basket,
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_quantityFocus),
                ),

                const SizedBox(height: 16),

                // QUANTITY & UNIT
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityCtrl,
                        focusNode: _quantityFocus,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: AppInputDecorations.generalInputDecoration(
                          prefixIcon: Icons.confirmation_number,
                          label: 'Quantity',

                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return n == null || n <= 0
                              ? 'Enter a valid number'
                              : null;
                        },
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_unitFocus),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _unitCtrl,
                        focusNode: _unitFocus,
                        textInputAction: TextInputAction.next,
                        decoration: AppInputDecorations.generalInputDecoration(
                          label: 'Unit',
                          prefixIcon: Icons.straighten,
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_estCostFocus),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ESTIMATED COST
                TextFormField(
                  controller: _estCostCtrl,
                  focusNode: _estCostFocus,
                  textInputAction:
                  isAssistant ? TextInputAction.next : TextInputAction.done,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: AppInputDecorations.generalInputDecoration(
                    label: 'Estimated Cost',
                    prefixText: '৳ ',
                  ),
                  validator: (v) {
                    final c = double.tryParse(v ?? '');
                    return (c == null || c < 0)
                        ? 'Invalid cost'
                        : null;
                  },
                  onFieldSubmitted: (_) {
                    if (isAssistant && !_isPurchased) {
                      FocusScope.of(context).requestFocus(_actualCostFocus);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ACTUAL COST (Assistant only, if not purchased)
                if (isAssistant && !_isPurchased) ...[
                  TextFormField(
                    controller: _actualCostCtrl,
                    focusNode: _actualCostFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: AppInputDecorations.generalInputDecoration(
                      label: 'Actual Cost',
                      prefixIcon: Icons.money_off,
                    ),
                    // validator: (v) {
                    //   final c = double.tryParse(v ?? '');
                    //   return (c == null || c < 0)
                    //       ? 'Invalid cost'
                    //       : null;
                    // },
                  ),
                  const SizedBox(height: 16),
                ],

                // STATUS DROPDOWN
                if (!_isPurchased)
                  DropdownButtonFormField<OrderItemStatus>(
                    initialValue: _status,
                    decoration: AppInputDecorations.generalInputDecoration(
                      label: 'Status',
                    ),
                    items: OrderItemStatus.values.map((s) {
                      final label = s
                          .toString()
                          .split('.')
                          .last
                          .capitalizeFirst!;
                      return DropdownMenuItem(
                        value: s,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),

                const SizedBox(height: 24),

                // SAVE BUTTON
                CustomButton(
                  icon: Icons.save,
                  buttonText: _isNew ? 'Add Item' : 'Save Changes',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
