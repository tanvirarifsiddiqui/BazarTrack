import 'package:flutter/material.dart';

class AssistantDashboard extends StatelessWidget {
  const AssistantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant Dashboard')),
      body: const Center(child: Text('Assistant tasks here')),
    );
  }
}
