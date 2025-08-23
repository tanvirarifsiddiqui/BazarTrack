import 'package:flutter_boilerplate/features/finance/repository/assistant_finance_repo.dart';
import 'package:get/get.dart';
import '../model/finance.dart';

class AssistantFinanceController extends GetxController {
  final AssistantFinanceRepo assistantFinanceRepo;

  AssistantFinanceController({ required this.assistantFinanceRepo, });

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


  var hasFilter = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadWalletForAssistant() async {
    isLoadingWallet.value = true;
    balance.value      = await assistantFinanceRepo.getWalletBalance(userId!);
    transactions.value = await assistantFinanceRepo.getWalletTransactions(userId!);
    isLoadingWallet.value = false;
  }

  Future<void> loadPayments() async {
    isLoadingWallet.value = true;
    final list = await assistantFinanceRepo.getPayments(userId: userId , type:   filterType.value, from:   filterFrom.value, to:     filterTo.value,);
    balance.value = await assistantFinanceRepo.getWalletBalance(userId!);
    transactions.assignAll(list);
    isLoadingWallet.value = false;
  }

  // Set any filter and reload
  void setFilters({String? type, DateTime? from, DateTime? to,}) {
    filterType.value   = type;
    filterFrom.value   = from;
    filterTo.value     = to;
    hasFilter.value = filterType.value != null || filterFrom.value  != null || filterTo.value != null;
    loadPayments();
  }

  void clearFilters() {
    filterType.value   = null;
    filterFrom.value   = null;
    filterTo.value     = null;
    hasFilter.value = false;
    loadPayments();
  }

  Future<void> addDebitForAssistant(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'debit',
      createdAt: DateTime.now(),
    );
    await assistantFinanceRepo.createPayment(f);
    await loadWalletForAssistant();
  }
}