import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../util/input_decoration.dart';
import '../../../util/colors.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_finance_tile.dart';
import '../auth/controller/auth_controller.dart';
import '../auth/model/role.dart';
import 'controller/assistant_finance_controller.dart';
import 'model/assistant.dart';

class AssistantFinancePage extends StatelessWidget {
  final Assistant? assistant;
  const AssistantFinancePage({super.key, this.assistant});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl        = Get.find<AssistantFinanceController>();
    final auth        = Get.find<AuthController>();
    final role        = auth.currentUser?.role;
    final isOwner     = role == UserRole.owner;
    final userId      = assistant?.id ?? int.parse(auth.currentUser!.id);
    ctrl.userId       = userId; // triggers wallet load

    final displayName = assistant?.name ?? auth.currentUser!.name;
    final numFmt      = NumberFormat.currency(locale: 'en_BD', symbol: '৳');
    final theme       = Theme.of(context);
    final ts          = theme.textTheme;

    return Scaffold(
      appBar: isOwner?CustomAppBar(
        title: "$displayName’s Wallet",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: ctrl.clearFilters,
          ),
        ],
      ): null,
      body: RefreshIndicator(
        onRefresh: () async => ctrl.clearFilters(),
        child: CustomScrollView(
          slivers: [
            // ─── SUMMARY CARD ────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
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
                          backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.12),
                          child: Text(
                            _getInitials(displayName),
                            style: ts.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: ts.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current balance',
                                style: ts.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
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
                            children: [
                              Text(
                                numFmt.format(ctrl.balance.value),
                                style: ts.headlineSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available',
                                style: ts.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── TRANSACTIONS HEADER ─────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(
                height: 56,
                child: _TransactionsHeader(
                  onFilter: () => _showFilterDialog(context, ctrl),
                  onClear: ctrl.clearFilters,
                  showClear: ctrl.hasFilter,
                ),
              ),
            ),

            // ─── TRANSACTIONS LIST ───────────────────
            Obx(() {
              if (ctrl.isLoadingWallet.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final tx = ctrl.transactions;
              if (tx.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.receipt_long,
                    message: 'No transactions yet.',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    child: CustomFinanceTile(
                        finance: tx[i], numFormat: numFmt),
                  ),
                  childCount: tx.length,
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Debit'),
        backgroundColor: AppColors.primary,
        onPressed: () => _showDebitDialog(context, ctrl, userId),
      )
          : null,
    );
  }

  Future<void> _showFilterDialog(
      BuildContext context, AssistantFinanceController ctrl) {
    String?   type   = ctrl.filterType.value;
    DateTime? from   = ctrl.filterFrom.value;
    DateTime? to     = ctrl.filterTo.value;
    final df = DateFormat('yyyy-MM-dd');

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: type,
                decoration: AppInputDecorations.generalInputDecoration(
                    label: 'Type', prefixIcon: Icons.swap_horiz),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(value: 'credit', child: Text('Credit')),
                  const DropdownMenuItem(value: 'debit', child: Text('Debit')),
                ],
                onChanged: (v) => setState(() => type = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: from != null ? df.format(from!) : 'Any'),
                      decoration: AppInputDecorations.generalInputDecoration(
                          label: 'From', prefixIcon: Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: ctx,
                          initialDate: from ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (dt != null) setState(() => from = dt);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: to != null ? df.format(to!) : 'Any'),
                      decoration: AppInputDecorations.generalInputDecoration(
                          label: 'To', prefixIcon: Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: ctx,
                          initialDate: to ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (dt != null) setState(() => to = dt);
                      },
                    ),
                  ),
                ],
              ),

            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ctrl.setFilters(type: type, from: from, to: to);
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDebitDialog(
      BuildContext context, AssistantFinanceController ctrl, int userId) {
    final amtCtrl = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Debit Expense', style: Theme.of(ctx).textTheme.titleLarge),
          ],
        ),
        content: TextFormField(
          controller: amtCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: AppInputDecorations.generalInputDecoration(
              label: 'Amount', prefixIcon: Icons.currency_exchange_rounded),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Save'),
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
              if (amt > 0) {
                ctrl.addDebitForAssistant(userId, amt)
                    .then((_) => Navigator.pop(ctx));
              }
            },
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate never shrinks to ensure header
// stays pinned at exactly its full height.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _HeaderDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;  // <-- keep full height

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(
        elevation: overlapsContent ? 4 : 0,
        child: SizedBox(height: height, child: child),
      );

  @override
  bool shouldRebuild(covariant _HeaderDelegate old) =>
      old.child != child || old.height != height;
}

// ─── HEADER WIDGET ────────────────────────────────────────────
class _TransactionsHeader extends StatelessWidget {
  final VoidCallback onFilter;
  final VoidCallback onClear;
  final RxBool showClear;

  const _TransactionsHeader({
    required this.onFilter,
    required this.onClear,
    required this.showClear,
  });

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Transactions', style: ts.titleLarge),
          const Spacer(),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: onFilter),
          Obx(() {
            if (showClear.value) {
              return IconButton(icon: const Icon(Icons.clear), onPressed: onClear);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: ts.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
