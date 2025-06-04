import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/role_guard.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';

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
              onPressed: () {
                if (RoleGuard.ensureOwner()) {
                  Get.snackbar('Action', 'Assign order logic here');
                }
              },
              child: const Text('Assign Order'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (RoleGuard.ensureOwner()) {
                  Get.toNamed(RouteHelper.advance);
                }
              },
              child: const Text('Record Advance'),
            ),
          ],
        ),
      ),
    );
  }
}
