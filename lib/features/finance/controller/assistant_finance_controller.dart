import 'package:flutter_boilerplate/features/finance/service/assistant_finance_service.dart';
import 'package:get/get.dart';
import '../../auth/model/role.dart';
import '../model/finance.dart';
import '../../auth/service/auth_service.dart';

class AssistantFinanceController extends GetxController {
  final AssistantFinanceService service;
  final AuthService    auth;

  AssistantFinanceController({ required this.service, required this.auth });

  // Owner flows
  var isLoadingAssistants = false.obs;
  bool get isOwner     => auth.currentUser?.role == UserRole.owner.toApi();



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