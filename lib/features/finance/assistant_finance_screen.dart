/*
// Title: Assistant Finance Page (polished)
// Description: Assistant wallet + transactions (static header, scrollable transactions)
// Author: Md. Tanvir Arif Siddiqui
// Date: August 11, 2025
*/

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/finance_input_decoration.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../util/colors.dart';
import 'controller/assistant_finance_controller.dart';
import 'model/assistant.dart';
import 'model/finance.dart';
import 'package:flutter_boilerplate/base/custom_finance_tile.dart';

class AssistantFinancePage extends StatefulWidget {
  final Assistant? assistant;
  const AssistantFinancePage({super.key, this.assistant});

  @override
  State<AssistantFinancePage> createState() => _AssistantFinancePageState();
}

class _AssistantFinancePageState extends State<AssistantFinancePage> {
  late final AssistantFinanceController ctrl;
  late final NumberFormat numFormat;
  late final int userId;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AssistantFinanceController>();
    numFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳');
    userId = widget.assistant?.id ?? int.parse(ctrl.auth.currentUser!.id);

    // Load wallet once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadWalletForAssistant(userId);
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = widget.assistant?.name ?? ctrl.auth.currentUser!.name;

    return Scaffold(
      appBar: AppBar(
        title: Text("$displayName's Wallet"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.loadWalletForAssistant(userId),
          ),
        ],
      ),

      // body: static header + transactions list (scrollable)
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card (balance area is reactive)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        _initials(displayName),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Name and label (static)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Current balance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Balance (observed)
                    Obx(() {
                      if (ctrl.isLoadingWallet.value) {
                        return SizedBox(
                          width: 110,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            numFormat.format(ctrl.balance.value),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Available',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Transactions header (static)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Transactions',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Filter',
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () {
                    // Add filters (All / Credit / Debit) can be applied
                  },
                ),
              ],
            ),
          ),

          // Transactions list (scrollable & reactive)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ctrl.loadWalletForAssistant(userId),
              child: Obx(() {
                final List<Finance> tx = ctrl.transactions;

                if (tx.isEmpty && ctrl.isLoadingWallet.value == false) {
                  // keep a scrollable view so user can pull-to-refresh
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 56,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(
                              height: 200,
                            ), // so pull-to-refresh is possible
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return ctrl.isLoadingWallet.value
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: tx.length,
                      itemBuilder:
                          (_, i) => CustomFinanceTile(
                            finance: tx[i],
                            numFormat: numFormat,
                          ),
                    );
              }),
            ),
          ),
        ],
      ),

      // FAB visible for Assistant only (isOwner is non-reactive getter)
      floatingActionButton:
          !ctrl.isOwner
              ? FloatingActionButton.extended(
                heroTag: 'assistant_add',
                icon: const Icon(Icons.add),
                label: const Text('Debit'),
                backgroundColor: AppColors.primary,
                onPressed: () => _showCreditDialog(context),
              )
              : null,
    );
  }

  void _showCreditDialog(BuildContext context) {
    final amtCtrl = TextEditingController();
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
                  'Debit Expense',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amtCtrl,
                  decoration: AppInputDecorations.financeInputDecoration(
                    label: "Amount",
                    hint: 'Enter credit amount',
                    prefixIcon: Icons.currency_exchange_rounded,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
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
                    final selectedId =
                        widget.assistant?.id ??
                        int.parse(ctrl.auth.currentUser!.id);
                    ctrl
                        .addDebitForAssistant(selectedId, amt)
                        .then((_) => Navigator.pop(context));
                  }
                },
              ),
            ],
          ),
    );
  }
}
