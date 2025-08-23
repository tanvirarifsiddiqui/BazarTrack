import 'package:flutter/material.dart';

import '../model/order_item.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const OrderItemCard({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Edit & Delete
            Row(
              children: [
                Text('Item', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 8),

            // Read-only fields
            _readOnlyField('Product', item.productName),
            const SizedBox(height: 6),
            _readOnlyField('Quantity', item.quantity.toString()),
            const SizedBox(height: 6),
            _readOnlyField('Unit', item.unit),
            const SizedBox(height: 6),
            _readOnlyField('Est. Cost', item.estimatedCost != null ? '৳ ${item.estimatedCost}' : '-'),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}