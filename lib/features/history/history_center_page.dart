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
              childrenPadding: const EdgeInsets.all(12),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: snapshot.entries.map((e) {
        final key = e.key;
        final value = e.value;

        if (key == 'items' && value is List) {
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
      key: PageStorageKey('history_items_table_scroll_${items.length}'),
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
