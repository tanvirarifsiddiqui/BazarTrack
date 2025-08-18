/*
// Title: Finance Controller
// Description: Business Logic for Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:17 PM
*/

import 'package:get/get.dart';
import '../../auth/service/auth_service.dart';
import '../model/finance.dart';
import '../model/assistant.dart';
import '../service/finance_service.dart';

class FinanceController extends GetxController {
  final FinanceService service;

  FinanceController({ required this.service, });

  // Owner flows
  var assistants          = <Assistant>[].obs;
  var isLoadingAssistants = false.obs;

  // Assistant wallet flows
  var isLoadingWallet    = false.obs;
  final AuthService    auth = Get.find();

  // Reactive list and loading flag
  var payments    = <Finance>[].obs;
  var isLoading   = false.obs;

  // Filter parameters
  var filterUserId = RxnInt();
  var filterType   = RxnString();
  var filterFrom   = Rxn<DateTime>();
  var filterTo     = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadAssistantsAndTransactions();
  }

  Future<void> loadPayments() async {
    isLoading.value = true;
    final list = await service.fetchPayments(userId: filterUserId.value, type:   filterType.value, from:   filterFrom.value, to:     filterTo.value,);
    payments.assignAll(list);
    isLoading.value = false;
  }

  // Set any filter and reload
  void setFilters({int? userId, String? type, DateTime? from, DateTime? to,}) {
    filterUserId.value = userId;
    filterType.value   = type;
    filterFrom.value   = from;
    filterTo.value     = to;
    loadPayments();
  }

  void clearFilters() {
    filterUserId.value = null;
    filterType.value   = null;
    filterFrom.value   = null;
    filterTo.value     = null;
    loadPayments();
  }


  Future<void> loadAssistantsAndTransactions() async {
    isLoadingAssistants.value = true;
    assistants.value = await service.fetchAssistants(withBalance: true);
    loadAllTransactions();
    isLoadingAssistants.value = false;
  }

  Future<void> addPaymentFor(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'credit',         // only owner can credit
      createdAt: DateTime.now(),
    );
    await service.recordPayment(f);
    // optionally refresh balance & list
    loadAssistantsAndTransactions();
  }

  Future<void> loadAllTransactions() async {
    isLoadingWallet.value = true;
    payments.value = await service.fetchPayments();
    isLoadingWallet.value = false;
  }

  Future<void> addCreditForAssistant(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'credit',
      createdAt: DateTime.now(),
    );
    await service.recordPayment(f);
    await loadAssistantsAndTransactions();
  }
}