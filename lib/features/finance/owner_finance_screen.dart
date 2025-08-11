/*
// Title: Finance UI
// Description: Presentation Layer for Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:41 PM
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'assistant_finance_screen.dart';
import 'controller/finance_controller.dart';

class OwnerFinancePage extends StatelessWidget {
  const OwnerFinancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FinanceController>();
    final fmt  = NumberFormat.currency(symbol: '৳');

    return Scaffold(
      appBar: AppBar(title: const Text('Assistants Wallets')),
      body: Obx(() {
        if (ctrl.isLoadingAssistants.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.assistants.length,
          itemBuilder: (_, i) {
            final a = ctrl.assistants[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(a.name[0])),
                title:   Text(a.name),
                subtitle: a.balance != null
                    ? Text('Balance: ${fmt.format(a.balance)}')
                    : null,
                onTap: () => Get.to(() => AssistantFinancePage(assistant: a)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'owner_add',
        child: const Icon(Icons.attach_money),
        onPressed: () {
          // e.g. open dialog to select assistant & amount, then:
          _showCreditDialog(context, ctrl);
        },
      ),
    );
  }

  void _showCreditDialog(BuildContext c, FinanceController ctrl) {
    final amtCtrl = TextEditingController();
    int selectedId = ctrl.assistants.first.id;

    showDialog<void>(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text('Credit Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: selectedId,
              items: ctrl.assistants
                  .map((a) => DropdownMenuItem(
                value: a.id,
                child: Text(a.name),
              ))
                  .toList(),
              onChanged: (v) => selectedId = v ?? selectedId,
              decoration: const InputDecoration(labelText: 'Assistant'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amtCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
              ctrl.addCreditForAssistant(selectedId, amt)
                  .then((_) => Navigator.pop(c));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}