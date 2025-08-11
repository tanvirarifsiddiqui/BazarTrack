import 'package:get/get.dart';
import '../model/finance.dart';
import '../model/assistant.dart';
import '../service/finance_service.dart';
import '../../auth/service/auth_service.dart';

class AssistantFinanceController extends GetxController {
  final FinanceService service;
  final AuthService    auth;

  AssistantFinanceController({ required this.service, required this.auth });

  // Owner flows
  var assistants          = <Assistant>[].obs;
  var isLoadingAssistants = false.obs;

  // Assistant wallet flows
  var balance            = 0.0.obs;
  var transactions       = <Finance>[].obs;
  var isLoadingWallet    = false.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   if (isAssistant)
  //     _loadWalletForCurrentUser();
  // }

  Future<void> _loadAssistants() async {
    isLoadingAssistants.value = true;
    assistants.value = await service.fetchAssistants(withBalance: true);
    isLoadingAssistants.value = false;
  }

  Future<void> addPaymentFor(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'credit',         // only owner can credit
      createdAt: DateTime.now(),
    );
    final created = await service.recordPayment(f);
    // optionally refresh balance & list
    _loadAssistants();
  }

  Future<void> loadWalletForAssistant(int assistantId) async {
    isLoadingWallet.value = true;
    balance.value      = await service.fetchBalance(assistantId);
    transactions.value = await service.fetchTransactions(assistantId);
    isLoadingWallet.value = false;
  }

  Future<void> addCreditForAssistant(int assistantId, double amount) async {
    final f = Finance(
      userId:    assistantId,
      amount:    amount,
      type:      'debit',
      createdAt: DateTime.now(),
    );
    await service.recordPayment(f);
    await loadWalletForAssistant(assistantId);
  }
}