import 'package:flutter_boilerplate/features/finance/service/assistant_finance_service.dart';
import 'package:get/get.dart';
import '../model/finance.dart';

class AssistantFinanceController extends GetxController {
  final AssistantFinanceService service;

  AssistantFinanceController({ required this.service });

  // Owner flows
  var isLoadingAssistants = false.obs;

  int? userId;
  // Assistant wallet flows
  var balance            = 0.0.obs;
  var transactions       = <Finance>[].obs;
  var isLoadingWallet    = false.obs;

  // Filter parameters
  var filterType   = RxnString();
  var filterFrom   = Rxn<DateTime>();
  var filterTo     = Rxn<DateTime>();
  // @override
  // void onInit() {
  //   super.onInit();
  //   if (isAssistant)
  //     _loadWalletForCurrentUser();
  // }

  Future<void> loadWalletForAssistant() async {
    isLoadingWallet.value = true;
    balance.value      = await service.fetchBalance(userId!);
    transactions.value = await service.fetchTransactions(userId!);
    isLoadingWallet.value = false;
  }

  Future<void> loadPayments() async {
    isLoadingWallet.value = true;
    final list = await service.fetchPayments(userId: userId, type:   filterType.value, from:   filterFrom.value, to:     filterTo.value,);
    transactions.assignAll(list);
    isLoadingWallet.value = false;
  }

  // Set any filter and reload
  void setFilters({int? userId, String? type, DateTime? from, DateTime? to,}) {
    filterType.value   = type;
    filterFrom.value   = from;
    filterTo.value     = to;
    loadPayments();
  }

  void clearFilters() {
    filterType.value   = null;
    filterFrom.value   = null;
    filterTo.value     = null;
    loadPayments();
  }


  Future<void> addDebitForAssistant(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'debit',
      createdAt: DateTime.now(),
    );
    await service.recordPayment(f);
    await loadWalletForAssistant();
  }
}