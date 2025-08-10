/*
// Title: Finance Controller
// Description: Business Logic for Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:17 PM
*/

import 'package:get/get.dart';
import '../model/finance.dart';
import '../service/finance_service.dart';

class FinanceController extends GetxController {
  final FinanceService service;
  FinanceController({ required this.service });

  var payments   = <Finance>[].obs;
  var isLoading  = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    isLoading.value = true;
    payments.value = await service.fetchPayments();
    isLoading.value = false;
  }

  Future<void> addPayment(Finance f) async {
    final created = await service.recordPayment(f);
    payments.insert(0, created);
  }

  double get totalCredits => payments
      .where((p) => p.type == 'credit')
      .fold(0.0, (sum, p) => sum + p.amount);

  double get totalDebits  => payments
      .where((p) => p.type == 'debit')
      .fold(0.0, (sum, p) => sum + p.amount);

  double get balance      => totalCredits - totalDebits;
}
