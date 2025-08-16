import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/history_controller.dart';
import 'model/history_log.dart';
import 'model/history_log_item.dart';

class HistoryCenterPage extends StatelessWidget {
  const HistoryCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HistoryController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History Logs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Orders'),
              Tab(text: 'Items'),
              Tab(text: 'Payments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HistoryList(
              loading: ctrl.isLoadingAll,
              logs:    ctrl.allLogs,
            ),
            _HistoryList(
              loading: ctrl.isLoadingOrder,
              logs:    ctrl.orderLogs,
            ),
            _HistoryList(
              loading: ctrl.isLoadingItem,
              logs:    ctrl.itemLogs,
            ),
            _HistoryList(
              loading: ctrl.isLoadingPayment,
              logs:    ctrl.paymentLogs,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable widget for a single tab’s list
class _HistoryList extends StatelessWidget {
  final RxBool            loading;
  final RxList<HistoryLog> logs;

  const _HistoryList({
    required this.loading,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mma');

    return Obx(() {
      if (loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (logs.isEmpty) {
        return const Center(child: Text('No history entries.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            // 1) Unique key per tile
            key: ValueKey('${log.entityType}_${log.id}'),
            child: ExpansionTile(
              // 2) Force a bool, never reuse old state
              key: PageStorageKey('exp_${log.entityType}_${log.id}'),
              initiallyExpanded: false,
              title: Text('${log.entityType} · ${log.action}'),
              subtitle: Text(fmt.format(log.timestamp)),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
              expandedAlignment: Alignment.centerLeft,
              children: [
                _buildSnapshot(log.dataSnapshot),
              ],
            ),
          );
        },
      );
    });
  }


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
      key: PageStorageKey('history_items_table_scroll_${items.length}'),
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
