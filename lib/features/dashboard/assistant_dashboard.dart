import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:get/get.dart';

class AssistantDashboard extends StatelessWidget {
  const AssistantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed(RouteHelper.getOrdersRoute()),
          child: const Text('View Orders'),
        ),
      ),
    );
  }
}
