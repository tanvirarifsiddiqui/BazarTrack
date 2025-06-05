import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/role_guard.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:get/get.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('owner_dashboard'.tr)),
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
              child: Text('assign_order'.tr),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (RoleGuard.ensureOwner()) {
                  Get.toNamed(RouteHelper.advance);
                }
              },
              child: Text('record_advance'.tr),
            ),
            const SizedBox(height: 16),
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
