import 'package:flutter_boilerplate/features/finance/repository/assistant_finance_repo.dart';
import 'package:get/get.dart';
import '../model/finance.dart';

class AssistantFinanceService extends GetxService {
  final AssistantFinanceRepo repo;
  AssistantFinanceService({ required this.repo });

  Future<List<Finance>> fetchPayments({int? userId, String? type, DateTime? from, DateTime? to}) {
    return repo.getPayments(userId: userId, type: type, from: from, to: to);
  }
  Future<Finance>       recordPayment(Finance f) => repo.createPayment(f);

  Future<double>        fetchBalance(int uid)   => repo.getWalletBalance(uid);
  Future<List<Finance>> fetchTransactions(int uid) =>
      repo.getWalletTransactions(uid);

}