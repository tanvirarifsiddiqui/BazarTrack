/*
// Title: Finance Controller (fixed error handling & loading states)
// Description: Business Logic for Finance Feature
// Author: Md. Tanvir Arif Siddiqui (patched)
// Date: August 10, 2025
// Time: 05:17 PM
*/

import 'package:flutter_boilerplate/features/finance/repository/finance_repo.dart';
import 'package:get/get.dart';
import '../model/finance.dart';
import '../model/assistant.dart';

class FinanceController extends GetxController {
  final FinanceRepo financeRepo;
  static const _pageSize = 30;

  FinanceController({
    required this.financeRepo,
  });

  // Owner flows
  var assistants = <Assistant>[].obs;
  var isLoadingAssistants = false.obs;

  // Reactive list and loading flag
  var payments = <Finance>[].obs;
  var isLoading = false.obs;

  // Filter parameters
  var filterUserId = RxnInt();
  var filterType = RxnString();
  var filterFrom = Rxn<DateTime>();
  var filterTo = Rxn<DateTime>();

  // Paging for payments
  var isInitialLoading = false.obs;
  var isLoadingMore    = false.obs;
  var hasMore          = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssistantsAndPayments();
  }

  bool get hasActiveFilters =>
      filterUserId.value != null ||
          filterType.value   != null ||
          filterFrom.value   != null ||
          filterTo.value     != null;

  void _showError(String title, Object error, [StackTrace? st]) {
    Get.snackbar(title, error.toString(), snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> loadPayments() async {
    isLoading.value = true;
    try {
      final list = await financeRepo.getPayments(
        userId: filterUserId.value,
        type: filterType.value,
        from: filterFrom.value,
        to: filterTo.value,
      );
      payments.assignAll(list);
    } catch (e, st) {
      // Clear stale data to avoid showing outdated UI state
      payments.clear();
      _showError('Failed to load payments', e, st);
    } finally {
      isLoading.value = false;
    }
  }

  // Set any filter and reload
  // Note: kept as void to avoid changing call sites; loadPayments handles async.
  void setFilters({
    int? userId,
    String? type,
    DateTime? from,
    DateTime? to,
  }) {
    filterUserId.value = userId;
    filterType.value = type;
    filterFrom.value = from;
    filterTo.value = to;
    loadPayments(); // loadPayments has its own error handling
  }

  void clearFilters() {
    filterUserId.value = null;
    filterType.value = null;
    filterFrom.value = null;
    filterTo.value = null;
    loadPayments();
  }

  Future<void> loadAssistantsAndPayments() async {
    // load assistants first (error handling omitted for brevity)
    isLoadingAssistants.value = true;
    final a = await financeRepo.getAssistants(withBalance: true);
    assistants.assignAll(a);
    isLoadingAssistants.value = false;

    // then load payments initial page
    await loadInitialPayments();
  }

  Future<void> loadAssistants() async {
    // load assistants first (error handling omitted for brevity)
    isLoadingAssistants.value = true;
    final a = await financeRepo.getAssistants(withBalance: true);
    assistants.assignAll(a);
    isLoadingAssistants.value = false;
  }

  Future<void> loadInitialPayments() async {
    hasMore.value = true;
    payments.clear();
    isInitialLoading.value = true;
    await _fetchPage(reset: true);
    isInitialLoading.value = false;
  }

  Future<void> loadMorePayments() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _fetchPage();
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({ bool reset = false }) async {
    final cursor = reset || payments.isEmpty ? null : payments.last.id;
    final page = await financeRepo.getPayments(
      userId: filterUserId.value,
      type:   filterType.value,
      from:   filterFrom.value,
      to:     filterTo.value,
      limit:  _pageSize,
      cursor: cursor,
    );

    payments.addAll(page);
    if (page.length < _pageSize) {
      hasMore.value = false;
    }
  }

  Future<void> loadAssistantsAndTransactions() async {
    isLoadingAssistants.value = true;
    try {
      final list = await financeRepo.getAssistants(withBalance: true);
      assistants.assignAll(list);
      // Await transactions load so any exception bubbles here and is handled
      await loadPayments();
    } catch (e, st) {
      assistants.clear();
      _showError('Failed to load assistants', e, st);
    } finally {
      isLoadingAssistants.value = false;
    }
  }

  Future<void> addPaymentFor(int assistantId, double amount) async {
    final finance = Finance(
      userId: assistantId,
      amount: amount,
      type: 'credit', // only owner can credit
      createdAt: DateTime.now(),
    );

    try {
      // Record payment
      await financeRepo.createPayment(finance);
      // refresh balance & list; await to catch any errors here too
      await loadAssistantsAndTransactions();
    } catch (e, st) {
      _showError('Failed to add payment', e, st);
    }
  }

  Future<void> addCreditForAssistant(int assistantId, double amount) async {
    final finance = Finance(
      userId: assistantId,
      amount: amount,
      type: 'credit',
      createdAt: DateTime.now(),
    );

    try {
      await financeRepo.createPayment(finance);
      await loadAssistantsAndTransactions();
    } catch (e, st) {
      _showError('Failed to add credit', e, st);
    }
  }
}
