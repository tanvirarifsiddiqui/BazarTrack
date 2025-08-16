import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/history_controller.dart';

class HistoryViewPage extends StatelessWidget {
  final String entity;
  final int? entityId;

  const HistoryViewPage({
    Key? key,
    required this.entity,
    this.entityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HistoryController(historyService: Get.find()));
    final fmt  = DateFormat('dd MMM yyyy, hh:mm a');

    // Load logs
    if (entityId != null) {
      ctrl.loadByEntityId(entity, entityId!);
    } else {
      ctrl.loadByEntity(entity);
    }
// here i want to create a page specially for history. here I want to show 4 tabs for history (all, order, order_item, payment) basically [order, order_item, payment] these 3 type of entity. I want to show them individually. different Page and all tab i want to show all history)
    return Scaffold(
      appBar: AppBar(title: Text('History: $entity')),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.logs.isEmpty) {
          return const Center(child: Text('No history found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.logs.length,
          itemBuilder: (_, i) {
            final log = ctrl.logs[i];
            return ExpansionTile(
              title: Text('${log.action} by User ${log.changedByUserId}'),
              subtitle: Text(fmt.format(log.timestamp)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildSnapshot(log.dataSnapshot),
                )
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) return const Text('No snapshot data');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: snapshot.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is List) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$key:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...value.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(item.toString()),
              )),
            ],
          );
        }

        return Text('$key: $value');
      }).toList(),
    );
  }
}
