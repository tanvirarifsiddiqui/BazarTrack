import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../../../util/input_decoration.dart';
import '../controller/order_controller.dart';

/// Dropdown to assign an assistant
class AssistantSelector extends StatelessWidget {
  final OrderController ctrl;
  const AssistantSelector({required this.ctrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => DropdownButtonFormField<int?>(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),

        initialValue: ctrl.assignedToUserId.value,
        items: [
          const DropdownMenuItem(value: null, child: Text("None")),
          ...ctrl.assistants
              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
        ],
        onChanged: (v) => ctrl.assignedToUserId.value = v,
        decoration: AppInputDecorations.generalInputDecoration(
          label: 'Select Assistant',
          prefixIcon: Icons.person,
        ),
      ),
    );
  }
}