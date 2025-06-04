import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/role_guard.dart';
import 'package:get/get.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (RoleGuard.ensureOwner()) {
              Get.snackbar('Action', 'Assign order logic here');
            }
          },
          child: const Text('Assign Order'),
        ),
      ),
    );
  }
}
