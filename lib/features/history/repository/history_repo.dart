import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import '../model/history_log.dart';

class HistoryRepo {
  final BazarTrackApi api;
  HistoryRepo({required this.api});

  /// GET /api/history?limit=&cursor=&changed_by=
  Future<List<HistoryLog>> getAll({
    int limit = 30,
    int? cursor,
    int? changedBy,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (cursor != null) query['cursor'] = cursor;
    if (changedBy != null) query['changed_by'] = changedBy;

    final res = await api.history(query: query);
    if (!res.isOk || res.body is! List) return [];
    return (res.body as List)
        .map((e) => HistoryLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HistoryLog>> getByEntity(
    String entity, {
    int limit = 30,
    int? cursor,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (cursor != null) query['cursor'] = cursor;

    final res = await api.historyByEntity(entity, query: query);
    if (!res.isOk || res.body is! List) return [];
    return (res.body as List)
        .map((e) => HistoryLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HistoryLog>> getByEntityId(String entity, int id) async {
    final res = await api.historyByEntityId(
      entity,
      id,
    ); // endpoint: /history/order/30
    if (res.isOk && res.body is! Map<String, dynamic>) {
      final data = res.body;

      if (data is List) {
        return data.map((e) => HistoryLog.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<HistoryLog> create(HistoryLog log) async {
    final res = await api.createHistory(log.toJson());
    if (res.isOk && res.body is Map<String, dynamic>) {
      return HistoryLog.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to create history log');
  }

  Future<bool> delete(int id) async {
    final res = await api.deleteHistory(id);
    return res.isOk;
  }
}
