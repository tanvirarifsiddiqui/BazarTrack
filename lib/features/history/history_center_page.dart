// lib/features/history/screens/history_center_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/history_controller.dart';
import 'model/history_log.dart';

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
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');

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
        itemBuilder: (ctx, i) {
          final log = logs[i];
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

  /// Renders the `dataSnapshot` map (handles nested lists)
  Widget _buildSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) return const Text('No snapshot data.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: snapshot.entries.map((e) {
        final key = e.key;
        final val = e.value;
        if (val is List) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$key:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...val.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(item.toString()),
              )),
              const SizedBox(height: 8),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('$key: $val'),
        );
      }).toList(),
    );
  }
}
