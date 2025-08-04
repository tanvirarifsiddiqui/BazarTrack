import 'package:flutter_boilerplate/features/finance/model/advance.dart';
import 'package:flutter_boilerplate/features/finance/service/advance_service.dart';
import 'package:get/get.dart';

class AdvanceController extends GetxController {
  final AdvanceService advanceService;
  AdvanceController({required this.advanceService});

  List<Advance> get advances => advanceService.advances;

  Future<void> addAdvance(Advance advance) async {
    await advanceService.addAdvance(advance);
    update();
  }

  Future<void> recordPurchase(double amount, String description) async {
    await advanceService.recordPurchase(amount, description);
    update();
  }
}
