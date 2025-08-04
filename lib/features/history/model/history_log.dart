import 'package:flutter_boilerplate/helper/date_converter.dart';

class HistoryLog {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String changedByUserId;
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

  factory HistoryLog.fromJson(Map<String, dynamic> json) => HistoryLog(
        id: json['id'].toString(),
        entityType:
            json['entityType'] ?? json['entity_type'] ?? '',
        entityId:
            (json['entityId'] ?? json['entity_id'] ?? '').toString(),
        action: json['action'] ?? '',
        changedByUserId: (json['changedByUserId'] ??
                json['changed_by_user_id'] ??
                '')
            .toString(),
        timestamp: DateConverter.parseApiDate(json['timestamp']),
        dataSnapshot: Map<String, dynamic>.from(
            json['dataSnapshot'] ?? json['data_snapshot'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'changed_by_user_id': changedByUserId,
        'timestamp': DateConverter.formatApiDate(timestamp),
        'data_snapshot': dataSnapshot,
      };
}
