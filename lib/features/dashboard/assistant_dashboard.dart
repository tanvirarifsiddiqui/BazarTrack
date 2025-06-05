import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';

class AssistantDashboard extends StatelessWidget {
  const AssistantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (auth) {
      final balance = auth.currentUser?.wallet.balance ?? 0;
      return Scaffold(
        appBar: AppBar(title: Text('assistant_dashboard'.tr)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('wallet_balance'.tr + ': \$${balance.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(RouteHelper.getOrdersRoute()),
                child: const Text('View Orders'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
