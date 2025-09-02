import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/finance/controller/assistant_finance_controller.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../../../util/input_decoration.dart';

/// OwnerSelector
/// - Shows Owner name in a Dropdown
/// - Uses Obx to react to changes in controller's assistants / assignedToUserId
/// - Non-blocking: shows a disabled hint when list is empty
class OwnerSelector extends StatelessWidget {
  final AssistantFinanceController ctrl;
  final String label;
  final ValueChanged<int?>? onChanged;
  final bool includeNoneOption;

  const OwnerSelector({
    super.key,
    required this.ctrl,
    this.label = 'Select Owner',
    this.onChanged,
    this.includeNoneOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final owners = ctrl.owners; // RxList expected
      final int? selectedId = ctrl.assignedToOwnerId.value;

      // If selected id no longer exists in the list, show null (keeps UI consistent)
      final bool selectedExists = selectedId != null && owners.any((owner) => owner.id == selectedId);
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

      if (owners.isEmpty) {
        // No assistants: show single disabled item so UI still renders
        items.add(
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('No owners available'),
          ),
        );
      } else {
        for (final owner in owners) {
          items.add(
            DropdownMenuItem<int?>(
              value: owner.id,
              child: Row(
                children: [
                  // initials avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    child: Text(
                      _initials(owner.name!),
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
                      owner.name!,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      final bool enabled = owners.isNotEmpty;

      return DropdownButtonFormField<int?>(
        initialValue: valueToShow,
        items: items,
        onChanged: enabled
            ? (int? v) {
          // Update controller value
          ctrl.assignedToOwnerId.value = v;
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
