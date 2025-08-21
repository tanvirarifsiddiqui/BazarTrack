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

  @override
  void onInit() {
    super.onInit();
    loadAssistantsAndTransactions();
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

  // Future<void> loadAllTransactions() async {
  //   isLoading.value = true;
  //   try {
  //     final list = await service.fetchPayments();
  //     payments.value = list;
  //   } catch (e, st) {
  //     payments.clear();
  //     _showError('Failed to load transactions', e, st);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
