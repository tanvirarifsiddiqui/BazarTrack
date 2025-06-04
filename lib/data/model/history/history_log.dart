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
        id: json['id'],
        entityType: json['entityType'],
        entityId: json['entityId'],
        action: json['action'],
        changedByUserId: json['changedByUserId'],
        timestamp: DateTime.parse(json['timestamp']),
        dataSnapshot: Map<String, dynamic>.from(json['dataSnapshot'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'action': action,
        'changedByUserId': changedByUserId,
        'timestamp': timestamp.toIso8601String(),
        'dataSnapshot': dataSnapshot,
      };
}
