import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../util/input_decoration.dart';
import '../../../util/colors.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_button.dart';
import '../../base/custom_finance_tile.dart';
import '../../base/empty_state.dart';
import '../../base/price_format.dart';
import '../../util/dimensions.dart';
import '../auth/model/role.dart';
import 'components/owner_selector.dart';
import 'controller/assistant_finance_controller.dart';
import 'model/assistant.dart';

class AssistantFinancePage extends StatefulWidget {
  final Assistant? assistant;
  const AssistantFinancePage({Key? key, this.assistant}) : super(key: key);

  @override
  State<AssistantFinancePage> createState() => _AssistantFinancePageState();
}

class _AssistantFinancePageState extends State<AssistantFinancePage> {
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  late AssistantFinanceController ctrl;
  late AuthService auth;
  @override
  void initState() {
    ctrl = Get.find<AssistantFinanceController>();
    auth = ctrl.auth;
    ctrl.assistantId = widget.assistant!.id;
    ctrl.prepareAndLoadingPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final role = auth.currentUser?.role;
    final isOwner = role == UserRole.owner;
    final displayName = widget.assistant?.name ?? auth.currentUser!.name;
    final theme = Theme.of(context);
    final ts = theme.textTheme;

    return Obx(() {
      // FULL-SCREEN LOADER on first page or balance load
      if (ctrl.isInitialLoading.value || ctrl.isLoadingBalance.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // ACTUAL PAGE
      return Scaffold(
        appBar:
            isOwner
                ? CustomAppBar(
                  title: "$displayName’s Wallet",
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                      onPressed: ctrl.clearFilters,
                    ),
                  ],
                )
                : null,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ctrl.clearFilters(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (sn) {
              if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100) {
                ctrl.loadMoreTransactions();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                // ── SUMMARY CARD ───────────────────
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
                              backgroundColor: theme.primaryColor.withValues(
                                alpha: 0.12,
                              ),
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
                                    style: ts.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Current balance',
                                    style: ts.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatPrice(ctrl.balance.value),
                                  style: ts.headlineSmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Available',
                                  style: ts.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── FILTER HEADER ────────────────────
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

                // ── TRANSACTIONS LIST ───────────────
                if (ctrl.transactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: const EmptyState(
                      icon: Icons.receipt_long,
                      message: 'No transactions yet.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: CustomFinanceTile(finance: ctrl.transactions[i]),
                      ),
                      childCount: ctrl.transactions.length,
                    ),
                  ),

                // ── BOTTOM LOADER ───────────────────
                if (ctrl.isLoadingMore.value)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── DEBIT FAB ─────────────────────────
        floatingActionButton:
            !isOwner
                ? FloatingActionButton.extended(
                  heroTag: 'debit',
                  icon: const Icon(Icons.add),
                  label: const Text('Debit'),
                  backgroundColor: AppColors.primary,
                  onPressed:
                      () => _showDebitDialog(context, ctrl, ctrl.assistantId),
                )
                : null,
      );
    });
  }
}

Future<void> _showFilterDialog(
  BuildContext context,
  AssistantFinanceController ctrl,
) {
  String? type = ctrl.filterType.value;
  DateTime? from = ctrl.filterFrom.value;
  DateTime? to = ctrl.filterTo.value;
  final df = DateFormat('yyyy-MM-dd');

  return showDialog(
    context: context,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setState) => AlertDialog(
                title: const Text('Filter Transactions'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String?>(
                      initialValue: type,
                      decoration: AppInputDecorations.generalInputDecoration(
                        label: 'Type',
                        prefixIcon: Icons.swap_horiz,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        const DropdownMenuItem(
                          value: 'credit',
                          child: Text('Credit'),
                        ),
                        const DropdownMenuItem(
                          value: 'debit',
                          child: Text('Debit'),
                        ),
                      ],
                      onChanged: (v) => setState(() => type = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: from != null ? df.format(from!) : 'Any',
                            ),
                            decoration:
                                AppInputDecorations.generalInputDecoration(
                                  label: 'From',
                                  prefixIcon: Icons.calendar_today,
                                ),
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
                            controller: TextEditingController(
                              text: to != null ? df.format(to!) : 'Any',
                            ),
                            decoration:
                                AppInputDecorations.generalInputDecoration(
                                  label: 'To',
                                  prefixIcon: Icons.calendar_today,
                                ),
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
                  CustomButton(
                    btnColor: Colors.redAccent,
                    height: MediaQuery.of(context).size.height * .04,
                    width: MediaQuery.of(context).size.width * .25,
                    onPressed: () => Navigator.pop(ctx),
                    buttonText: 'Cancel',
                  ),
                  CustomButton(
                    btnColor: AppColors.primary,
                    height: MediaQuery.of(context).size.height * .04,
                    width: MediaQuery.of(context).size.width * .25,
                    onPressed: () {
                      ctrl.setFilters(type: type, from: from, to: to);
                      Navigator.pop(ctx);
                    },
                    buttonText: 'Apply',
                  ),
                ],
                actionsAlignment: MainAxisAlignment.spaceAround,

              ),
        ),
  );
}

Future<void> _showDebitDialog(
  BuildContext context,
  AssistantFinanceController ctrl,
  int userId,
) {
  final amtCtrl = TextEditingController();

  return showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Dimensions.inputFieldBorderRadius,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text('Debit Expense', style: Theme.of(ctx).textTheme.titleLarge),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OwnerSelector(ctrl: ctrl),

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
            CustomButton(
              btnColor: Colors.redAccent,
              height: MediaQuery.of(context).size.height * .04,
              width: MediaQuery.of(context).size.width * .25,
              onPressed: () => Navigator.pop(ctx),
              buttonText: 'Cancel',
            ),
            CustomButton(
              btnColor: AppColors.primary,
              height: MediaQuery.of(context).size.height * .04,
              width: MediaQuery.of(context).size.width * .25,
              icon: Icons.check_circle_outline_rounded,
              buttonText: 'Save',
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amt > 0) {
                  ctrl.addDebit(amt).then((_) => Navigator.pop(ctx));
                }
              },
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,

        ),
  );
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _HeaderDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height; // <-- keep full height

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
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
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
