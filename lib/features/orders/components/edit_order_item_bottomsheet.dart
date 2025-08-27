import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/util/input_decoration.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; //
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_item.dart';
import '../../../base/custom_unit_dropdown.dart';
import '../../../helper/route_helper.dart';
class EditOrderItemBottomSheet extends StatefulWidget {
  final String orderId;
  final OrderItem item;
  final bool autoFocusFirstField;
  final ScrollController? scrollController;


  const EditOrderItemBottomSheet({
    Key? key,
    required this.orderId,
    required this.item,
    required this.autoFocusFirstField,
    this.scrollController,
  }) : super(key: key);

  @override
  _EditOrderItemBottomSheetState createState() =>
      _EditOrderItemBottomSheetState();
}

class _EditOrderItemBottomSheetState extends State<EditOrderItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _estCostCtrl;
  late final TextEditingController _actualCostCtrl;

  final _productFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _unitFocus = FocusNode();
  final _estCostFocus = FocusNode();
  final _actualCostFocus = FocusNode();

  late OrderItemStatus _status;
  late bool _isPurchased;
  bool _saving = false;

  // NEW state for quantity widget
  int _currentQty = 0;
  final int _minQuantity = 1;

  bool get _isNew => widget.item.id == null;

  final _orderController = Get.find<OrderController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final itm = widget.item;
    _isPurchased = itm.status == OrderItemStatus.purchased;
    _status = itm.status;
    _productCtrl = TextEditingController(text: itm.productName);
    _quantityCtrl = TextEditingController(text: itm.quantity.toString());
    _unitCtrl = TextEditingController(text: itm.unit);
    _estCostCtrl =
        TextEditingController(text: itm.estimatedCost?.toString() ?? '');
    _actualCostCtrl =
        TextEditingController(text: itm.actualCost?.toString() ?? '');

    // initialize _currentQty from controller / item
    _currentQty = int.tryParse(_quantityCtrl.text) ?? itm.quantity;
    if (_currentQty < _minQuantity) _currentQty = _minQuantity;
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

  // NEW helper to update qty
  void _setQty(int v) {
    if (v < _minQuantity) v = _minQuantity;
    setState(() {
      _currentQty = v;
      _quantityCtrl.text = v.toString();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? widget.item.quantity;
    final est = double.tryParse(_estCostCtrl.text.trim());
    final actual = double.tryParse(_actualCostCtrl.text.trim());

    final updated = widget.item.copyWith(
      orderId: int.parse(widget.orderId),
      productName: _productCtrl.text.trim(),
      quantity: qty,
      unit: _unitCtrl.text.trim(),
      estimatedCost: est,
      actualCost: actual,
      status: _status,
    );

    try {
      if (_isNew) {
        final created = await _orderController.createOrderItem(updated);
        Navigator.pop(context, created); // return created
      } else {
        await _orderController.updateOrderItem(updated, _isPurchased);
        Navigator.pop(context, updated); // return updated
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _orderController.deleteOrderItem(widget.item);
      Navigator.pop(context); // close sheet after delete
      Get.snackbar('Deleted', 'Item removed', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAssistant = _authController.user.value?.role == UserRole.assistant;
    final topPadding = 12.0;

    return Material(
      // ensures theme and ripple on controls
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: topPadding,
            ),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // small drag handle
                  Container(
                    width: 40,
                    height: 4,
                    // margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Title + actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isNew ? 'Add Item' : 'Edit Item',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (!_isNew)IconButton(
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
                          if (_isNew)IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reset',
                            onPressed: () {
                              _productCtrl.clear();
                              _quantityCtrl.clear();
                              _setQty(1);
                              _estCostCtrl.clear();
                              _actualCostCtrl.clear();
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PRODUCT NAME
                        if(!_isPurchased)TextFormField(
                          controller: _productCtrl,
                          focusNode: _productFocus,
                          textInputAction: TextInputAction.next,
                          decoration: AppInputDecorations.generalInputDecoration(label: "Product Name", prefixIcon: Icons.shopping_basket),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_quantityFocus),
                        ),

                        const SizedBox(height: 16),

                        // QUANTITY & UNIT
                        Row(
                          children: [
                            // <-- REPLACED QUANTITY WIDGET START
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 56,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // The actual TextField (fills area)
                                    TextFormField(
                                      controller: _quantityCtrl,
                                      focusNode: _quantityFocus,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ).copyWith(
                                        // leave horizontal padding so text doesn't touch floating buttons
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 42,
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (v) {
                                        final n = int.tryParse(v ?? '');
                                        return n == null || n <= 0 ? 'Enter a valid number' : null;
                                      },
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_unitFocus),
                                      onChanged: (val) {
                                        final parsed = int.tryParse(val.trim());
                                        setState(() {
                                          _currentQty = parsed ?? 0;
                                        });
                                      },
                                    ),

                                    // A full-area GestureDetector that focuses the field when user taps outside the buttons
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          _quantityFocus.requestFocus();
                                        },
                                        child: const SizedBox.expand(),
                                      ),
                                    ),

                                    // Decrement button (left)
                                    Positioned(
                                      left: 4,
                                      child: IconButton(
                                        icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          if (_currentQty > _minQuantity) _setQty(_currentQty - 1);
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
                                            icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _setQty(_currentQty + 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // <-- REPLACED QUANTITY WIDGET END

                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: UnitDropdown(
                                value: _unitCtrl.text.isEmpty ? null : _unitCtrl.text, // sync with controller
                                onChanged: (val) {
                                  _unitCtrl.text = val ?? ""; // store short form (e.g. "kg")
                                },
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 16),

                        // ESTIMATED COST
                        TextFormField(
                          controller: _estCostCtrl,
                          focusNode: _estCostFocus,
                          textInputAction: isAssistant ? TextInputAction.next : TextInputAction.done,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Estimated Cost',
                            prefixText: '৳ ',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final c = double.tryParse(v ?? '');
                            return (c == null || c < 0) ? 'Invalid cost' : null;
                          },
                          onFieldSubmitted: (_) {
                            if (isAssistant && !_isPurchased) {
                              FocusScope.of(context).requestFocus(_actualCostFocus);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // ACTUAL COST (Assistant only, if not purchased)
                        if (isAssistant) ...[
                          TextFormField(
                            controller: _actualCostCtrl,
                            focusNode: _actualCostFocus,
                            textInputAction: TextInputAction.done,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Actual Cost',
                              prefixIcon: const Icon(Icons.money_off),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final c = double.tryParse(v ?? '');
                              return (c == null || c < 0) ? 'Invalid cost' : null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // STATUS DROPDOWN
                        if (!_isPurchased)
                          DropdownButtonFormField<OrderItemStatus>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: OrderItemStatus.values.map((s) {
                              final label = s.toString().split('.').last.capitalizeFirst!;
                              return DropdownMenuItem(value: s, child: Text(label));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _status = v);
                            },
                          ),

                        const SizedBox(height: 18),

                        // SAVE BUTTON
                        CustomButton(
                          icon: Icons.save,
                          buttonText: _isNew ? 'Add Item' : 'Save Changes',
                          onPressed: _saving ? null : _save,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
