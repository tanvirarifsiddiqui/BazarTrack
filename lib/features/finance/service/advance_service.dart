import 'package:flutter_boilerplate/features/finance/model/advance.dart';
import 'package:flutter_boilerplate/features/finance/model/wallet_transaction.dart';
import 'package:flutter_boilerplate/features/finance/repository/advance_repo.dart';
import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/history/service/history_service.dart';
import 'package:get/get.dart';

class AdvanceService extends GetxController implements GetxService {
  final AdvanceRepo advanceRepo;
  AdvanceService({required this.advanceRepo});

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

    final auth = Get.find<AuthService>();
    final user = auth.currentUser;
    if (user != null) {
      user.wallet.balance += advance.amount;
      user.wallet.transactions.add(WalletTransaction(
        amount: advance.amount,
        type: TransactionType.credit,
        createdAt: advance.date,
        description: 'Advance from ${advance.givenBy}',
      ));
      await auth.saveUser(user);
      Get.find<HistoryService>().addLog(
        HistoryLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: 'Wallet',
          entityId: user.id,
          action: 'advance',
          changedByUserId: auth.currentUser?.id ?? '',
          timestamp: DateTime.now(),
          dataSnapshot: {
            'after': user.wallet.toJson(),
          },
        ),
      );
    }
    update();
  }

  Future<void> recordPurchase(double amount, String description) async {
    final auth = Get.find<AuthService>();
    final user = auth.currentUser;
    if (user != null) {
      user.wallet.balance -= amount;
      user.wallet.transactions.add(WalletTransaction(
        amount: amount,
        type: TransactionType.debit,
        createdAt: DateTime.now(),
        description: description,
      ));
      await auth.saveUser(user);
      Get.find<HistoryService>().addLog(
        HistoryLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          entityType: 'Wallet',
          entityId: user.id,
          action: 'purchase',
          changedByUserId: user.id,
          timestamp: DateTime.now(),
          dataSnapshot: {
            'after': user.wallet.toJson(),
          },
        ),
      );
      update();
    }
  }
}
