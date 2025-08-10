/*
// Title: Finance Service
// Description: Getx Service Finance Feature
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 05:11 PM
*/

import 'package:get/get.dart';
import '../model/finance.dart';
import '../repository/finance_repo.dart';

class FinanceService extends GetxService {
  final FinanceRepo repo;
  FinanceService({ required this.repo });

  Future<List<Finance>> fetchPayments() => repo.payments();

  Future<Finance> recordPayment(Finance f) => repo.createPayment(f);
}
