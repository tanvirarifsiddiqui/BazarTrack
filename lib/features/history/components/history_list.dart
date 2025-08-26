import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/app_format.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../model/history_log.dart';
import '../model/history_log_item.dart';

class HistoryList extends StatelessWidget {
  final RxBool loading;
  final RxBool loadingMore;
  final RxBool hasMore;
  final RxList<HistoryLog> logs;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  const HistoryList({
    super.key,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.logs,
    required this.onLoadMore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = AppFormats.appDateTimeFormat;
    return Obx(() {
      if (loading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
      }
      if (logs.isEmpty) {
        return const Center(child: Text('No history entries.'));
      }
      return RefreshIndicator(
        onRefresh: ()async{
          onRefresh();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (sn){
            if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100 &&
                hasMore.value &&
                !loadingMore.value) {
              onLoadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              if(index> logs.length){
                return Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary,),
                ));
              }
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2, // optional for shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                clipBehavior: Clip.antiAlias,
                key: ValueKey('${log.entityType}_${log.id}'),
                child: ExpansionTile(
                  key: PageStorageKey('exp_${log.entityType}_${log.id}'),
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _entityColor(
                            log.entityType,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          log.entityType.toUpperCase(),

                          style: TextStyle(
                            color: _entityColor(log.entityType),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          log.action,

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  subtitle: Text(fmt.format(log.timestamp)),

                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  expandedAlignment: Alignment.centerLeft,

                  children: [_buildSnapshot(log.dataSnapshot)],
                ),
              );
            },
          ),
        ),
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
          items =
              value
                  .whereType<Map<String, dynamic>>()
                  .map((m) => HistoryLogItem.fromJson(m))
                  .toList();
        }
      } else {
        rows.add(
          DataRow(
            cells: [
              DataCell(
                Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),

              DataCell(Text(': ${value ?? ''}')),
            ],
          ),
        );
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          key: PageStorageKey('history_items_table_scroll_${snapshot.length}'),
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
          ),
        ),

        const SizedBox(height: 12),

        if (items.isNotEmpty)
          _buildItemsTable(items)
        else
          const SizedBox.shrink(),
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
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              "Items:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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

  /// Choose a subtle color depending on entity type (tweak as you like)

  Color _entityColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return const Color(0xFF6D5DF6); // indigo-ish

      case 'order_item':
        return const Color(0xFF2DBD7E); // green-ish

      case 'payment':
        return const Color(0xFFFFA726); // orange

      default:
        return const Color(0xFF9E9E9E); // grey
    }
  }
}
