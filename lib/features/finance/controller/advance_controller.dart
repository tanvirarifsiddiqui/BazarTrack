import 'package:flutter_boilerplate/data/model/advance/advance.dart';
import 'package:flutter_boilerplate/data/model/transaction/wallet_transaction.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/finance/repository/advance_repo.dart';
import 'package:get/get.dart';

class AdvanceController extends GetxController {
  final AdvanceRepo advanceRepo;
  AdvanceController({required this.advanceRepo});

  final List<Advance> _advances = [];
  List<Advance> get advances => _advances;

  @override
  void onInit() {
    _advances.addAll(advanceRepo.getAdvances());
    super.onInit();
  }

  Future<void> addAdvance(Advance advance) async {
    _advances.add(advance);
    await advanceRepo.saveAdvances(_advances);

    final auth = Get.find<AuthController>();
    final user = auth.currentUser;
    if (user != null) {
      user.wallet.balance += advance.amount;
      user.wallet.transactions.add(WalletTransaction(
        amount: advance.amount,
        type: TransactionType.advance,
        date: advance.date,
        description: 'Advance from ${advance.givenBy}',
      ));
      await auth.saveUser(user);
    }
    update();
  }

  Future<void> recordPurchase(double amount, String description) async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser;
    if (user != null) {
      user.wallet.balance -= amount;
      user.wallet.transactions.add(WalletTransaction(
        amount: amount,
        type: TransactionType.purchase,
        date: DateTime.now(),
        description: description,
      ));
      await auth.saveUser(user);
      update();
    }
  }
}
