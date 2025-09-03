import 'history_log_item.dart';

class HistoryLog {
  final int id;
  final String entityType;
  final int entityId;
  final String action;
  final int changedByUserId;
  final DateTime timestamp;
  final Map<String, dynamic> dataSnapshot;

  HistoryLog({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.changedByUserId,
    required this.timestamp,
    required this.dataSnapshot,
  });

  factory HistoryLog.fromJson(Map<String, dynamic> json) {
    // data_snapshot can be a Map or an empty List
    final rawSnap = json['data_snapshot'];
    final Map<String, dynamic> snapshot = (rawSnap is Map<String, dynamic>)
        ? rawSnap
        : <String, dynamic>{};

    return HistoryLog(
      id:              json['id'] as int,
      entityType:      json['entity_type'] as String,
      entityId:        json['entity_id'] as int,
      action:          json['action'] as String,
      changedByUserId: json['changed_by_user_id'] as int,
      timestamp:       DateTime.parse(json['timestamp'] as String),
      dataSnapshot:    snapshot,
    );
  }

  List<HistoryLogItem> get items {
    final raw = dataSnapshot['items'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((m) => HistoryLogItem.fromJson(m))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
    'entity_type': entityType,
    'entity_id': entityId,
    'action': action,
    'data_snapshot': dataSnapshot,
  };
}
