import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import '../../../util/dimensions.dart';
import '../model/order_item.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const OrderItemCard({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12,),
            const Divider(height: 1, color: Colors.grey,),
            const SizedBox(height: 12),
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading icon badge
        _LeadingBadge(
          icon: Icons.inventory_2_rounded,
          background: AppColors.primary.withValues(alpha: 0.12),
          iconColor: AppColors.primary,
        ),
        const SizedBox(width: 12),

        // Title only (no description field in your model)
        Expanded(
          child: Text(
            item.productName,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),

        // Action buttons
        const SizedBox(width: 8),
        _CircleActionButton(
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          tooltip: 'Edit item',
          onPressed: onEdit,
        ),
        const SizedBox(width: 8),
        _CircleActionButton(
          icon: Icons.delete_outline,
          color: Colors.red.shade700,
          tooltip: 'Delete item',
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {

    // Use Wrap so items flow on narrow screens
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Quantity',
                value: item.quantity.toString(),
                leading: _SquareBadge(icon: Icons.production_quantity_limits),
              ),
            ),
            Expanded(
              child: _InfoTile(
                label: 'Price',
                value: _formatPrice(item.estimatedCost),
                leading: _SquareBadge(symbol: '৳'),
              ),
            ),
          ],
        ),
        _InfoTile(
          label: 'Unit',
          value: item.unit.isNotEmpty ? item.unit : '-',
          leading: _SquareBadge(icon: Icons.straighten),
        ),

      ],
    );
  }

  String _formatPrice(num? price) {
    if (price == null) return '-';
    // Keep minimal formatting; caller can adapt for locales
    return '৳ ${price is int ? price : price.toStringAsFixed(2)}';
  }
}


class _LeadingBadge extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;

  const _LeadingBadge({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: iconColor),
    );
  }
}

class _SquareBadge extends StatelessWidget {
  final IconData? icon;
  final String? symbol;

  const _SquareBadge({
    this.icon,
    this.symbol,
  })  : assert(icon != null || symbol != null, 'Provide icon or symbol');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 18, color: AppColors.primary)
          : Text(
        symbol!,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? tooltip;
  final VoidCallback onPressed;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: color),
        tooltip: tooltip,
        splashRadius: 20,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget leading;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.leading,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220, // comfortable width for each info tile; Wrap will reflow on small screens
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
