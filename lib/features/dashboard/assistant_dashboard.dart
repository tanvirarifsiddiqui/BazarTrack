import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';

class AssistantDashboard extends StatelessWidget {
  const AssistantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (auth) {
      final balance = auth.currentUser?.wallet.balance ?? 0;
      return Scaffold(
        appBar: AppBar(title: const Text('Assistant Dashboard')),
        body: Center(
          child: Text('wallet_balance'.tr + ': \$${balance.toStringAsFixed(2)}'),
        ),
      );
    });
  }
}
