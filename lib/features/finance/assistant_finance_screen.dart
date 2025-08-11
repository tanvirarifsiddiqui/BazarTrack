import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import 'controller/assistant_finance_controller.dart';
import 'model/assistant.dart';
import 'model/finance.dart';

class AssistantFinancePage extends StatelessWidget {
  final Assistant? assistant;
  const AssistantFinancePage({Key? key, this.assistant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AssistantFinanceController>();
    final fmt = NumberFormat.currency(symbol: '৳');
    final userId = assistant?.id ?? int.parse(ctrl.auth.currentUser!.id);

    // load that assistant’s wallet on enter
    ctrl.loadWalletForAssistant(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${assistant?.name ?? ctrl.auth.currentUser!.name}\'s Wallet'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (ctrl.isLoadingWallet.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadWalletForAssistant(userId),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Balance: ${fmt.format(ctrl.balance.value)}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...ctrl.transactions.map((t) => _buildTile(t, fmt)),
                if (ctrl.transactions.isEmpty)
                  const Center(child: Text('No transactions yet')),
              ],
            ),
          ),
        );
      }),
      floatingActionButton:ctrl.isOwner?FloatingActionButton(
        heroTag: 'assistant_add',
        // child: Text("৳",style: TextStyle(fontSize: 28),),
        child: Icon(Icons.add),
        onPressed: () {
          _showCreditDialog(context, ctrl);
        },
      ):null,
    );
  }

  void _showCreditDialog(BuildContext c, AssistantFinanceController ctrl) {
    final amtCtrl = TextEditingController();
    int selectedId = int.parse(ctrl.auth.currentUser!.id);

    showDialog<void>(
      context: c,
      builder:
          (_) => AlertDialog(
            title: const Text('Debit Assistant'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amtCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                  ctrl
                      .addCreditForAssistant(selectedId, amt)
                      .then((_) => Navigator.pop(c));
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
