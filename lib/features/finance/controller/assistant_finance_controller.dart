import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:get/get.dart';
import '../model/finance.dart';
import '../model/owner.dart';
import '../repository/assistant_finance_repo.dart';

class AssistantFinanceController extends GetxController {
  final AssistantFinanceRepo repo;
  final AuthService auth;
  static const _pageSize = 30;

  AssistantFinanceController({required this.repo, required this.auth});

  late int _assistantId;

  int get assistantId => _assistantId;

  set assistantId(int value) {
    _assistantId = value;
  }

  var owners = <Owner>[].obs;

  // ── Balance ────────────────────────────────────────
  var balance = 0.0.obs;
  var isLoadingBalance = false.obs;

  // ── Pagination state ─────────────────────────────
  var transactions = <Finance>[].obs;
  var isInitialLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  // ── Filters ──────────────────────────────────────
  var filterType = RxnString();
  var filterFrom = Rxn<DateTime>();
  var filterTo = Rxn<DateTime>();
  var hasFilter = false.obs;
  var assignedToOwnerId = Rxn<int>();


  Future<void> prepareAndLoadingPayments() async {
    loadOwners();
    _loadBalance();
    _loadInitialTransactions();
  }

  Future<void> loadOwners() async {
    final ownerlist = await repo.getOwners();
    owners.assignAll(ownerlist);
  }


  Future<void> _loadBalance() async {
    isLoadingBalance.value = true;
    try {
      balance.value = await repo.getWalletBalance(_assistantId);
    } finally {
      isLoadingBalance.value = false;
    }
  }

  Future<void> _loadInitialTransactions() async {
    hasMore.value = true;
    transactions.clear();
    isInitialLoading.value = true;
    await _fetchPage(reset: true);
    isInitialLoading.value = false;
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _fetchPage();
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({bool reset = false}) async {
    final cursor = reset || transactions.isEmpty ? null : transactions.last.id;

    final page = await repo.getTransactions(
      userId: _assistantId,
      type: filterType.value,
      from: filterFrom.value,
      to: filterTo.value,
      limit: _pageSize,
      cursor: cursor,
    );

    transactions.addAll(page);
    if (page.length < _pageSize) {
      hasMore.value = false;
    }
  }

  void setFilters({String? type, DateTime? from, DateTime? to}) {
    filterType.value = type;
    filterFrom.value = from;
    filterTo.value = to;
    hasFilter.value = type != null || from != null || to != null;
    _loadInitialTransactions();
  }

  void clearFilters() {
    filterType.value = null;
    filterFrom.value = null;
    filterTo.value = null;
    hasFilter.value = false;
    _loadInitialTransactions();
  }

  Future<void> addRefund(double amount) async {
    final f = Finance(
      userId: _assistantId,
      ownerId: assignedToOwnerId.value,
      amount: amount,
      type: 'wallet',
      createdAt: DateTime.now(),
    );
    await repo.createPayment(f);
    await _loadBalance();
    await _loadInitialTransactions();
  }
}
