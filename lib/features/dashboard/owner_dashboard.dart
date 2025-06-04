import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/role_guard.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:get/get.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed(RouteHelper.getOrdersRoute()),
              child: const Text('View Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
