import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/price_format.dart';
import '../../../util/dimensions.dart';
import '../../../util/input_decoration.dart';
import '../controller/order_controller.dart';

/// AssistantSelector
/// - Shows assistant name + balance in a Dropdown
/// - Uses Obx to react to changes in controller's assistants / assignedToUserId
/// - Non-blocking: shows a disabled hint when list is empty
class AssistantSelector extends StatelessWidget {
  final OrderController ctrl;
  final String label;
  final ValueChanged<int?>? onChanged;
  final bool includeNoneOption;

  const AssistantSelector({
    Key? key,
    required this.ctrl,
    this.label = 'Select Assistant',
    this.onChanged,
    this.includeNoneOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final assistants = ctrl.assistants; // RxList expected
      final int? selectedId = ctrl.assignedToUserId.value;

      // If selected id no longer exists in the list, show null (keeps UI consistent)
      final bool selectedExists = selectedId != null && assistants.any((a) => a.id == selectedId);
      final int? valueToShow = selectedExists ? selectedId : null;

      // Build items
      final List<DropdownMenuItem<int?>> items = [];

      if (includeNoneOption) {
        items.add(
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('None'),
          ),
        );
      }

      if (assistants.isEmpty) {
        // No assistants: show single disabled item so UI still renders
        items.add(
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('No assistants available'),
          ),
        );
      } else {
        for (final assistant in assistants) {
          final balanceText = formatPrice(assistant.balance ?? 0);
          items.add(
            DropdownMenuItem<int?>(
              value: assistant.id,
              child: Row(
                children: [
                  // initials avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    child: Text(
                      _initials(assistant.name),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      assistant.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    balanceText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }
      }

      final bool enabled = assistants.isNotEmpty;

      return DropdownButtonFormField<int?>(
        initialValue: valueToShow,
        items: items,
        onChanged: enabled
            ? (int? v) {
          // Update controller value
          ctrl.assignedToUserId.value = v;
          // forward to optional callback
          if (onChanged != null) onChanged!(v);
        }
            : null,
        decoration: AppInputDecorations.generalInputDecoration(
          label: label,
          prefixIcon: Icons.person,
        ),
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
        isExpanded: true,
      );
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
