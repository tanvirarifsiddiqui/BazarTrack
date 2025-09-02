import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/util/app_format.dart';
import 'package:get/get.dart';
import '../../util/colors.dart';
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
    final ctrl = Get.find<HistoryController>();
    final fmt  = AppFormats.appDateTimeFormat;

    // Load logs
    if (entityId != null) {
      ctrl.loadByEntityId(entity, entityId!);
    } else {
      ctrl.loadByEntity(entity);
    }
// here i want to create a page specially for history. here I want to show 4 tabs for history (all, order, order_item, payment) basically [order, order_item, payment] these 3 type of entity. I want to show them individually. different Page and all tab i want to show all history)
    return Scaffold(
      appBar: CustomAppBar(title: 'History: $entity'),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
                expandedAlignment: Alignment.centerLeft,
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
      ),
    );
  }

  // Wherever you build the snapshot view, replace the items‐list case

  Widget _buildSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) return const Text('No snapshot data');

    final rows = <DataRow>[];
    List<HistoryLogItem> items = [];

    snapshot.forEach((key, value) {
      if (key == 'items') {
        if (value is List) {
          items = value
              .whereType<Map<String, dynamic>>()
              .map((m) => HistoryLogItem.fromJson(m))
              .toList();
        }
      } else {
        rows.add(
          DataRow(cells: [
            DataCell(Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(': ${value ?? ''}')),
          ]),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
            key: PageStorageKey('history_items_table_scroll_${snapshot.length}'),
            // scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 25,
              headingRowHeight: 25,
              horizontalMargin: 0,
              columnSpacing: 10,
              columns: const [
                DataColumn(
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Name'),
                  ),
                ),
                DataColumn(
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Value'),
                  ),
                ),
              ],
              rows: rows,
            )
        ),

        const SizedBox(height: 16),

        // --- Items table (only if present) ---
        if (items.isNotEmpty)
          _buildItemsTable(items)
        else
          const Text(''),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Items:", style: TextStyle(fontWeight: FontWeight.bold),),
          DataTable(
            dataRowHeight: 25,
            headingRowHeight: 25,
            horizontalMargin: 0,
            columnSpacing: 10,
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
        ],
      ),
    );
  }

}
