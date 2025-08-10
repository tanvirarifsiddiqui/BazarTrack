/*
// Title: Finance UI
// Description: Presentation Layer for Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:41 PM
*/
// lib/features/finance/screens/finance_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../auth/service/auth_service.dart';
import 'controller/finance_controller.dart';
import 'model/finance.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(FinanceController(service: Get.find()));
    final numFormat  = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: ctrl.loadPayments,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummary(context, ctrl, numFormat),
              const SizedBox(height: 24),
              Text('Transactions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...ctrl.payments.map((p) => _buildTile(p, numFormat)),
              if (ctrl.payments.isEmpty)
                const Center(child: Text('No transactions yet')),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'balance_add_item',
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context, ctrl, numFormat),
      ),
    );
  }

  Widget _buildSummary(BuildContext c, FinanceController ctrl, NumberFormat numFormat) {
    final theme = Theme.of(c);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Wallet Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _stat('Credits', numFormat.format(ctrl.totalCredits), Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _stat('Debits',  numFormat.format(ctrl.totalDebits),  Colors.red)),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Balance: ${numFormat.format(ctrl.balance)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ctrl.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: color)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _buildTile(Finance p, NumberFormat fmt) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: p.type == 'credit' ? Colors.green[50] : Colors.red[50],
        child: Icon(
          p.type == 'credit' ? Icons.arrow_upward : Icons.arrow_downward,
          color: p.type == 'credit' ? Colors.green : Colors.red,
        ),
      ),
      title: Text(fmt.format(p.amount)),
      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt)),
    ),
  );

  Future<void> _showAddDialog(BuildContext c, FinanceController ctrl, NumberFormat fmt) {
    final amtCtrl = TextEditingController();
    var type = 'credit';

    return showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(c).viewInsets.bottom, left: 16, right: 16, top: 16
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Record Payment', style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: amtCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              items: ['credit', 'debit']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => type = v!,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                final amount = double.tryParse(amtCtrl.text.trim()) ?? 0;
                final finance = Finance(
                  userId:    int.parse(Get.find<AuthService>().currentUser!.id),
                  amount:    amount,
                  type:      type,
                  createdAt: DateTime.now(),
                );
                ctrl.addPayment(finance).then((_) => Navigator.pop(c));
              },
            ),
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }
}

