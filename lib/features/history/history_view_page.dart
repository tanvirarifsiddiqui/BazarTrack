import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/history_controller.dart';
import 'model/history_log_item.dart';

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

  // Wherever you build the snapshot view, replace the items‐list case

  Widget _buildSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) return const Text('No snapshot data');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: snapshot.entries.map((e) {
        final key = e.key;
        final value = e.value;

        if (key == 'items' && value is List) {
          // Use your typed items getter if you have the log instance:
          // final items = log.items;
          // Here, rebuild from raw value:
          final items = (value)
              .whereType<Map<String, dynamic>>()
              .map((m) => HistoryLogItem.fromJson(m))
              .toList();
          return _buildItemsTable(items);
        }

        // Non‐items entries render as before
        if (value is List) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$key:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...value.map((v) => Text(v.toString()))
            ],
          );
        }

        return Text('$key: $value');
      }).toList(),
    );
  }

  /// DataTable to show products with nullable costs
  Widget _buildItemsTable(List<HistoryLogItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No items'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('Est. Cost')),
          DataColumn(label: Text('Act. Cost')),
          DataColumn(label: Text('Status')),
        ],
        rows: items.map((it) {
          return DataRow(cells: [
            DataCell(Text(it.productName)),
            DataCell(Text(it.quantity.toString())),
            DataCell(Text(it.unit)),
            DataCell(Text(it.estimatedCost?.toStringAsFixed(2) ?? '-')),
            DataCell(Text(it.actualCost?.toStringAsFixed(2)    ?? '-')),
            DataCell(Text(it.status)),
          ]);
        }).toList(),
      ),
    );
  }

}
