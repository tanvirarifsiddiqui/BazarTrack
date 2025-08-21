import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'components/assistant_selector.dart';
import 'components/create_list_of_order_item.dart';
import 'controller/order_controller.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      appBar: const CustomAppBar(title: 'New Order'),
      body: Column(
        children: [
          // 1) ASSISTANT SELECTOR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AssistantSelector(ctrl: ctrl),
          ),

          // 2) ITEMS LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OrderItemsList(ctrl: ctrl),
            ),
          ),

          // 3) ACTIONS: ADD ITEM & SAVE ORDER
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icons.add,
                    buttonText: 'Add Item',
                    onPressed: ctrl.addItem,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final hasItems = ctrl.newItems.isNotEmpty;
                    return CustomButton(
                      icon: Icons.save,
                      buttonText: 'Save Order',
                      onPressed: hasItems ? ctrl.saveNewOrder : null,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

