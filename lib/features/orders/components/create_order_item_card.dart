import 'package:flutter/material.dart';
import '../../../util/input_decoration.dart';
import '../model/order_item.dart';

/// Card for a single order item with fields
class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final ValueChanged<OrderItem> onChanged;
  final VoidCallback onDelete;

  const OrderItemCard({
    required this.item,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row with delete action
            Row(
              children: [
                Text(
                  'Item',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Product Name
            _buildField(
              label: 'Product Name',
              icon: Icons.shopping_basket,
              initialValue: item.productName,
              onChanged: (v) => onChanged(item.copyWith(productName: v)),
            ),

            const SizedBox(height: 8),

            // Quantity & Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    label: 'Quantity',
                    icon: Icons.confirmation_number,
                    initialValue: item.quantity.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final q = int.tryParse(v) ?? item.quantity;
                      onChanged(item.copyWith(quantity: q));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildField(
                    label: 'Unit',
                    icon: Icons.straighten,
                    initialValue: item.unit,
                    onChanged: (v) => onChanged(item.copyWith(unit: v)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Estimated Cost
            _buildField(
              label: 'Estimated Cost',
              prefixText: '৳ ',
              initialValue: item.estimatedCost?.toString() ?? '',
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final c = double.tryParse(v);
                onChanged(item.copyWith(estimatedCost: c));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    IconData? icon,
    String? initialValue,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: AppInputDecorations.generalInputDecoration(
        label: label,
        prefixIcon: icon,
        prefixText: prefixText
      ),
      onChanged: onChanged,
    );
  }
}