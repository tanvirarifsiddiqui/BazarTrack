import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../util/input_decoration.dart';
import '../../../util/colors.dart';
import '../../base/custom_finance_tile.dart';
import '../../base/empty_state.dart';
import '../../util/dimensions.dart';
import 'components/assistant_summary_card.dart';
import 'controller/finance_controller.dart';

class OwnerFinancePage extends StatelessWidget {
  const OwnerFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.find<FinanceController>();
    final fmt   = NumberFormat.currency(locale: 'en_BD', symbol: '৳');
    // final theme = Theme.of(context);
    // final ts    = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assistant Wallets & Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: ctrl.clearFilters,
          ),
        ],
      ),

      body: Obx(() {
        if (ctrl.isLoadingAssistants.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => ctrl.clearFilters(),
          child: CustomScrollView(
            slivers: [
              // ─── ASSISTANT SUMMARY ───────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: AssistantSummaryCard(
                    assistants: ctrl.assistants,
                    fmt: fmt,
                  ),
                ),
              ),

              // ─── TRANSACTIONS HEADER ─────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  child: _TransactionsHeader(
                    hasFilter: ctrl.hasActiveFilters,
                    onFilter: () => _showFilterDialog(context, ctrl),
                    onClear: ctrl.clearFilters,
                  ),
                  height: 56,
                ),
              ),

              // ─── TRANSACTIONS LIST ──────────────────────
              Obx(() {
                final tx = ctrl.payments;
                if (tx.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.receipt_long,
                      message: 'No transactions yet.',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: CustomFinanceTile(
                        finance: tx[i],
                        numFormat: fmt,
                      ),
                    ),
                    childCount: tx.length,
                  ),
                );
              }),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'owner_add',
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Credit'),
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreditDialog(context, Get.find<FinanceController>()),
      ),
    );
  }

  Future<void> _showFilterDialog(
      BuildContext context,
      FinanceController ctrl,
      ) async {
    final df = DateFormat('yyyy-MM-dd');
    int?     selectedUser = ctrl.filterUserId.value;
    String?  selectedType = ctrl.filterType.value;
    DateTime? fromDate    = ctrl.filterFrom.value;
    DateTime? toDate      = ctrl.filterTo.value;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Assistant
              DropdownButtonFormField<int?>(
                initialValue: selectedUser,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Assistant',
                  prefixIcon: Icons.person_outline,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...ctrl.assistants.map(
                        (a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => selectedUser = v),
              ),

              const SizedBox(height: 12),

              // Type
              DropdownButtonFormField<String?>(
                initialValue: selectedType,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Type',
                  prefixIcon: Icons.swap_horiz,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(value: 'credit', child: Text('Credit')),
                  const DropdownMenuItem(value: 'debit',  child: Text('Debit')),
                ],
                onChanged: (v) => setState(() => selectedType = v),
              ),

              const SizedBox(height: 12),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'From',
                        prefixIcon: Icons.calendar_today,
                      ),
                      controller: TextEditingController(
                        text: fromDate != null ? df.format(fromDate!) : 'Any',
                      ),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: fromDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => fromDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'To',
                        prefixIcon: Icons.calendar_today,
                      ),
                      controller: TextEditingController(
                        text: toDate != null ? df.format(toDate!) : 'Any',
                      ),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: toDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => toDate = d);
                      },
                    ),
                  ),
                ],
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
                ctrl.setFilters(
                  userId: selectedUser,
                  type: selectedType,
                  from: fromDate,
                  to: toDate,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreditDialog(
      BuildContext context,
      FinanceController ctrl,
      ) async {
    final amtCtrl = TextEditingController();
    int selectedId = ctrl.assistants.isNotEmpty
        ? ctrl.assistants.first.id
        : 0;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
          ),
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Credit Assistant',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedId,
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Select Assistant',
                  prefixIcon: Icons.person,
                ),
                items: ctrl.assistants
                    .map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text(a.name),
                ))
                    .toList(),
                onChanged: (v) => setState(() => selectedId = v!),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: AppInputDecorations.generalInputDecoration(
                  label: 'Amount',
                  hint: 'Enter amount',
                  prefixIcon: Icons.attach_money,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                if (amt > 0) {
                  ctrl.addCreditForAssistant(selectedId, amt)
                      .then((_) => Navigator.pop(context));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delegate for a pinned header.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _HeaderDelegate({required this.child, this.height = 56});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant _HeaderDelegate old) =>
      child != old.child || height != old.height;
}

/// Header row with title, filter & clear icons.
class _TransactionsHeader extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  const _TransactionsHeader({
    required this.hasFilter,
    required this.onFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text('All Transactions', style: ts.titleLarge),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilter,
            tooltip: 'Filter',
          ),
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
    );
  }
}
