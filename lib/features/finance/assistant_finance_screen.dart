/*
// Title: Assistant Finance Page (stateless, filters working)
// Description: Assistant wallet + transactions (static header, scrollable transactions)
// Author: Md. Tanvir Arif Siddiqui (refactor)
// Date: August 18, 2025
*/

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/util/finance_input_decoration.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../util/colors.dart';
import '../auth/model/role.dart';
import 'controller/assistant_finance_controller.dart';
import 'model/assistant.dart';
import 'model/finance.dart';
import 'package:flutter_boilerplate/base/custom_finance_tile.dart';

class AssistantFinancePage extends StatelessWidget {
  final Assistant? assistant;
  const AssistantFinancePage({super.key, this.assistant});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  void _showFilterDialog(BuildContext context, AssistantFinanceController ctrl) {
    // copy current controller values to local variables so dialog can edit them
    String? selectedType = ctrl.filterType.value;
    DateTime? fromDate = ctrl.filterFrom.value;
    DateTime? toDate = ctrl.filterTo.value;

    final df = DateFormat('yyyy-MM-dd');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        // use StatefulBuilder to manage local dialog state (so UI updates inside dialog)
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Transactions'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type filter
                    DropdownButtonFormField<String?>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [null, 'credit', 'debit'].map((t) {
                        return DropdownMenuItem<String?>(
                          value: t,
                          child: Text(t == null ? 'All' : t.capitalizeFirst!),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedType = v),
                    ),

                    const SizedBox(height: 8),

                    // Date range pickers
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => fromDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'From'),
                              child: Text(fromDate != null ? df.format(fromDate!) : 'Any'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => toDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'To'),
                              child: Text(toDate != null ? df.format(toDate!) : 'Any'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // quick clear inside dialog
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() {
                            selectedType = null;
                            fromDate = null;
                            toDate = null;
                          }),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // apply to controller and reload
                    ctrl.setFilters(type: selectedType, from: fromDate, to: toDate);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDebitDialog(BuildContext context, AssistantFinanceController ctrl, int selectedId) {
    final amtCtrl = TextEditingController();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 28, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Debit Expense', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amtCtrl,
              decoration: AppInputDecorations.generalInputDecoration(
                label: "Amount",
                hint: 'Enter debit amount',
                prefixIcon: Icons.currency_exchange_rounded,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Save'),
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
              if (amt > 0) {
                ctrl.addDebitForAssistant(selectedId, amt).then((_) {
                  Navigator.pop(context);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AssistantFinanceController ctrl = Get.find<AssistantFinanceController>();
    final AuthController auth = Get.find<AuthController>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    ctrl.userId = assistant?.id ?? int.parse(auth.currentUser!.id);

    final numFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳');
    final theme = Theme.of(context);
    final displayName = assistant?.name ?? auth.currentUser!.name;
    final selectedId = assistant?.id ?? int.parse(auth.currentUser!.id);

    // We trigger initial load only when there are no transactions and not loading.
    // Use Obx to observe controller state and call load once when needed.
    return Scaffold(
      appBar: AppBar(
        title: Text("$displayName's Wallet"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.clearFilters(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      // replaced with withOpacity for safe API
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                      child: Text(
                        _initials(displayName),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Current balance',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Balance (observed)
                    Obx(() {
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
                          Text('Available', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Transactions header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Transactions', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context, ctrl),
                ),
                // show clear icon only when any filter is active
                Obx(() {
                  final hasFilter = ctrl.filterType.value != null || ctrl.filterFrom.value != null || ctrl.filterTo.value != null;
                  if (!hasFilter) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      ctrl.clearFilters();
                    },
                    tooltip: 'Clear Filters',
                  );
                }),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ctrl.clearFilters(),
              child: Obx(() {
                // trigger initial load if needed (only when transactions empty & not loading)
                if (ctrl.transactions.isEmpty && ctrl.isLoadingWallet.value == false) {
                  // schedule a microtask so it doesn't happen during build
                  Future.microtask(() => ctrl.loadWalletForAssistant());
                }

                final List<Finance> tx = ctrl.transactions;

                if (tx.isEmpty && ctrl.isLoadingWallet.value == false) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No transactions yet', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                            const SizedBox(height: 200),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ctrl.isLoadingWallet.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tx.length,
                  itemBuilder: (_, i) => CustomFinanceTile(finance: tx[i], numFormat: numFormat),
                );
              }),
            ),
          ),
        ],
      ),

      // FAB visible for Assistant only (if controller exposes isOwner as bool)
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
        heroTag: 'assistant_add',
        icon: const Icon(Icons.add),
        label: const Text('Debit'),
        backgroundColor: AppColors.primary,
        onPressed: () => _showDebitDialog(context, ctrl, selectedId),
      )
          : null,
    );
  }
}
