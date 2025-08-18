/*
// Title: Finance Service
// Description: Getx Service Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:11 PM
*/

import 'package:get/get.dart';
import '../model/assistant.dart';
import '../model/finance.dart';
import '../repository/finance_repo.dart';

class FinanceService extends GetxService {
  final FinanceRepo repo;
  FinanceService({required this.repo});

  Future<List<Assistant>> fetchAssistants({bool withBalance = false}) =>
      repo.getAssistants(withBalance: withBalance);

  Future<List<Finance>> fetchPayments({int? userId, String? type, DateTime? from, DateTime? to}) {
    return repo.getPayments(userId: userId, type: type, from: from, to: to);
  }

  Future<void> recordPayment(Finance f) => repo.createPayment(f);

  Future<double> fetchBalance(int uid) => repo.getWalletBalance(uid);
}
