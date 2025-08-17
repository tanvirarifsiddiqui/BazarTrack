/*
 Title: Finance UI
 Description: Presentation Layer for Finance Feature
 Author: Md. Tanvir Arif Siddiqui
 Date: August 10, 2025
 Time: 05:41 PM
*/
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_finance_tile.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/finance_input_decoration.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'assistant_finance_screen.dart';
import 'components/assistant_row.dart';
import 'controller/finance_controller.dart';

class OwnerFinancePage extends StatelessWidget {
  const OwnerFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FinanceController>();
    final fmt = NumberFormat.currency(locale: 'en_BD', symbol: '৳');
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistants Wallets'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.loadAssistantsAndTransactions(),
          ),
        ],
      ),

      body: Obx(() {
        // initial loading of assistants
        if (ctrl.isLoadingAssistants.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // compute aggregate values
        final totalAssistants = ctrl.assistants.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Header row: title + count chip
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Assistants',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            backgroundColor: theme.primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            label: Text(
                              '$totalAssistants',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Assistants list (static — shrinkWrapped so it doesn't scroll independently)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ctrl.assistants.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final a = ctrl.assistants[idx];
                          return AssistantRow(
                            assistant: a,
                            fmt: fmt,
                            onTap:
                                () => Get.to(
                                  () => AssistantFinancePage(assistant: a),
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Transactions title (static)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All Transactions',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter',
                    icon: const Icon(Icons.filter_list_rounded),
                    onPressed: () {
                      //  Add filters (All / Credit / Debit) can be applied
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions list (scrollable & refreshable)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ctrl.loadAssistantsAndTransactions(),
                child: Obx(() {
                  final tx = ctrl.transactions;
                  if (tx.isEmpty) {
                    // show an empty, scrollable view so pull-to-refresh works
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 56,
                                color: AppColors.lightGray,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions yet',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.darkGray,
                                ),
                              ),
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: tx.length,
                    itemBuilder:
                        (_, i) =>
                            CustomFinanceTile(finance: tx[i], numFormat: fmt),
                  );
                }),
              ),
            ),
          ],
        );
      }),

      // FAB - keep behavior same as before (owner action)
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'owner_add',
        icon: const Icon(Icons.add),
        label: const Text('Credit'),
        backgroundColor: AppColors.primary,
        onPressed: () {
          _showCreditDialog(context, Get.find<FinanceController>());
        },
      ),
    );
  }

  void _showCreditDialog(BuildContext context, FinanceController ctrl) {
    final amtCtrl = TextEditingController();
    int selectedId = ctrl.assistants.isNotEmpty ? ctrl.assistants.first.id : 0;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            title: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 28,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Credit Assistant',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  borderRadius: BorderRadius.circular(12),
                  value: selectedId,
                  items:
                      ctrl.assistants
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => selectedId = v ?? selectedId,
                  decoration: AppInputDecorations.financeInputDecoration(
                    label: 'Select Assistant',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amtCtrl,
                  decoration: AppInputDecorations.financeInputDecoration(
                    label: 'Amount',
                    hint: 'Enter credit amount',
                    prefixIcon: Icons.currency_exchange_rounded,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textButtonTextColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text('Save'),
                onPressed: () {
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                  if (amt > 0) {
                    ctrl
                        .addCreditForAssistant(selectedId, amt)
                        .then((_) => Navigator.pop(context));
                  }
                },
              ),
            ],
          ),
    );
  }
}
