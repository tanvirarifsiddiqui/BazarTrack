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
import '../auth/model/role.dart';
import '../auth/service/auth_service.dart';
import 'controller/finance_controller.dart';
import 'model/finance.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeController = Get.put(FinanceController(service: Get.find()));
    final numFormat = NumberFormat.currency(symbol: '৳');
    final auth = Get.find<AuthService>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    final isAssistant = auth.currentUser?.role == UserRole.assistant;
    return Scaffold(
      body: Obx(() {
        if (financeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: financeController.loadPayments,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isAssistant) ...[
                _buildSummary(context, financeController, numFormat),
                const SizedBox(height: 24),
              ],
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...financeController.payments.map((p) => _buildTile(p, numFormat)),
              if (financeController.payments.isEmpty)
                const Center(child: Text('No transactions yet')),
            ],
          ),
        );
      }),
      floatingActionButton:
          isOwner
              ? FloatingActionButton(
                heroTag: 'finance_add',
                onPressed:
                    () => _showAddDialog(
                      context,
                      financeController,
                      numFormat,
                      isOwner,
                      isAssistant,
                    ),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildSummary(
    BuildContext c,
    FinanceController ctrl,
    NumberFormat numFormat,
  ) {
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
                Expanded(
                  child: _stat(
                    'Credits',
                    numFormat.format(ctrl.totalCredits),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _stat(
                    'Debits',
                    numFormat.format(ctrl.totalDebits),
                    Colors.red,
                  ),
                ),
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
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  Future<void> _showAddDialog(
    BuildContext c,
    FinanceController financeController,
    NumberFormat numberFormat,
    bool isOwner,
    bool isAssistant,
  ) {
    final amountController = TextEditingController();
    String type = isOwner ? 'credit' : 'debit';

    return showDialog<void>(
      context: c,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              // Only allow “credit” for owners, “debit” for assistants
              if (isOwner || isAssistant)
                DropdownButtonFormField<String>(
                  value: type,
                  items:
                      [if (isOwner) 'credit', if (isAssistant) 'debit']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                  onChanged: (v) => type = v ?? type,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                final userId = int.parse(
                  Get.find<AuthService>().currentUser!.id,
                );
                final finance = Finance(
                  userId: userId,
                  amount: amount,
                  type: type,
                  createdAt: DateTime.now(),
                );
                financeController.addPayment(finance).then((_) => Navigator.pop(ctx));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
