import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_button.dart';
import 'package:flutter_boilerplate/base/custom_text_field.dart';
import 'package:flutter_boilerplate/data/model/advance/advance.dart';
import 'package:flutter_boilerplate/features/finance/controller/advance_controller.dart';
import 'package:get/get.dart';

class AdvanceScreen extends StatefulWidget {
  const AdvanceScreen({super.key});

  @override
  State<AdvanceScreen> createState() => _AdvanceScreenState();
}

class _AdvanceScreenState extends State<AdvanceScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _givenByController = TextEditingController();
  final TextEditingController _receivedByController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _givenByController.dispose();
    _receivedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('advance'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _amountController,
              hintText: 'amount'.tr,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _givenByController,
              hintText: 'given_by'.tr,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _receivedByController,
              hintText: 'received_by'.tr,
            ),
            const SizedBox(height: 16),
            CustomButton(
              buttonText: 'add_advance'.tr,
              onPressed: () async {
                final amount = double.tryParse(_amountController.text) ?? 0;
                final advance = Advance(
                  amount: amount,
                  date: DateTime.now(),
                  givenBy: _givenByController.text,
                  receivedBy: _receivedByController.text,
                );
                await Get.find<AdvanceController>().addAdvance(advance);
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }
}
