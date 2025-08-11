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
  var transactions       = <Finance>[].obs;
  var isLoadingWallet    = false.obs;
  final AuthService    auth = Get.find();
  @override
  void onInit() {
    super.onInit();
    loadAssistantsAndTransactions();
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
    final created = await service.recordPayment(f);
    // optionally refresh balance & list
    loadAssistantsAndTransactions();
  }

  Future<void> loadAllTransactions() async {
    isLoadingWallet.value = true;
    transactions.value = await service.fetchPayments();
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