/*
 Title: Finance UI
 Description: Presentation Layer for Finance Feature
 Author: Md. Tanvir Arif Siddiqui
 Date: August 10, 2025
 Time: 05:41 PM
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'assistant_finance_screen.dart';
import 'controller/finance_controller.dart';
import 'model/finance.dart';

class OwnerFinancePage extends StatelessWidget {
  const OwnerFinancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FinanceController>();
    final fmt = NumberFormat.currency(symbol: '৳');

    return Scaffold(
      appBar: AppBar(title: const Text('Assistants Wallets')),
      body: Obx(() {
        if (ctrl.isLoadingAssistants.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadAssistantsAndTransactions(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Assistants List
              ...ctrl.assistants.map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(a.name[0])),
                  title: Text(a.name),
                  subtitle: a.balance != null
                      ? Text('Balance: ${fmt.format(a.balance)}')
                      : null,
                  onTap: () => Get.to(
                          () => AssistantFinancePage(assistant: a)),
                ),
              )),

              const SizedBox(height: 24),

              // Transactions Title
              Text(
                'All Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // Transactions List
              if (ctrl.transactions.isEmpty)
                const Center(child: Text('No transactions yet'))
              else
                ...ctrl.transactions.map((t) => _buildTile(t, fmt)),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'owner_add',
        child: const Icon(Icons.add),
        onPressed: () => _showCreditDialog(context, ctrl),
      ),
    );
  }

  void _showCreditDialog(BuildContext context, FinanceController ctrl) {
    final amtCtrl = TextEditingController();
    int selectedId = ctrl.assistants.isNotEmpty ? ctrl.assistants.first.id : 0;

    showDialog<void>(
      context: context,
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
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
              if (amt > 0) {
                ctrl
                    .addCreditForAssistant(selectedId, amt)
                    .then((_) => Navigator.pop(context));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(Finance t, NumberFormat fmt) {
    final credit = t.type == 'credit';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: credit ? Colors.green[50] : Colors.red[50],
      child: ListTile(
        leading: Icon(
          credit ? Icons.arrow_upward : Icons.arrow_downward,
          color: credit ? Colors.green : Colors.red,
        ),
        title: Text(
          fmt.format(t.amount),
          style: TextStyle(color: credit ? Colors.green : Colors.red),
        ),
        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(t.createdAt)),
      ),
    );
  }
}
