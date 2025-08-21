import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/finance_input_decoration.dart';
import '../controller/order_controller.dart';
import '../model/order_status.dart';

class FilterBar extends StatelessWidget {
  final OrderController ctrl;
  final bool isOwner;

  const FilterBar({
    Key? key,
    required this.ctrl,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Only one Expanded here
          Expanded(
            child: Obx(() {
              return DropdownButtonFormField<OrderStatus?>(
                value: ctrl.filterStatus.value,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Status',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...OrderStatus.values.map((s) {
                    final label = s
                        .toString()
                        .split('.')
                        .last
                        .capitalizeFirst!;
                    return DropdownMenuItem(
                      value: s,
                      child: Text(label),
                    );
                  }),
                ],
                onChanged: ctrl.setStatusFilter,
              );
            }),
          ),

          if (isOwner) const SizedBox(width: 12),

          if (isOwner)
            Expanded(
              child: Obx(() {
                return DropdownButtonFormField<int?>(
                  value: ctrl.filterAssignedTo.value,
                  decoration: AppInputDecorations.generalInputDecoration(
                    label: 'Assigned To',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...ctrl.assistants.map(
                          (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ),
                    )
                  ],
                  onChanged: ctrl.setAssignedToFilter,
                );
              }),
            ),
        ],
      ),
    );
  }
}
