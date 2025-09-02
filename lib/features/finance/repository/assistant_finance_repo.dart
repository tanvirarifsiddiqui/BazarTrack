import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import '../model/finance.dart';
import '../model/owner.dart';

class AssistantFinanceRepo {
  final BazarTrackApi api;
  AssistantFinanceRepo({ required this.api });

  Future<List<Finance>> getPayments({int? userId, String? type, DateTime? from, DateTime? to,int limit = 30, int? cursor,}) async {
    final query = <String, dynamic>{};
    if (userId != null) query['user_id'] = userId;
    if (type   != null) query['type']    = type;
    if (from   != null) query['from']    = from.toIso8601String().split('T').first;
    if (to     != null) query['to']      = to  .toIso8601String().split('T').first;
    query['limit']  = limit;
    if (cursor != null) query['cursor'] = cursor;

    final res = await api.payments(query: query.isEmpty ? null : query);
    if (res.isOk && res.body is List) {
      return (res.body as List)
          .map((e) => Finance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Finance> createPayment(Finance f) async {
    final res = await api.createPayment(f.toJsonForCreate());
    if (res.isOk && res.body is Map<String, dynamic>) {
      return Finance.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to record payment');
  }

  Future<double> getWalletBalance(int userId) async {
    final res = await api.wallet(userId);
    if (res.isOk && res.body is Map<String, dynamic>) {
      final body = res.body as Map<String, dynamic>;
      final raw  = body['balance'];
      if (raw is num)    return raw.toDouble();
      if (raw is String) return double.tryParse(raw) ?? 0.0;
    }
    throw Exception('Failed to fetch wallet');
  }

  Future<List<Finance>> getWalletTransactions(int userId) async {
    final res = await api.walletTransactions(userId);
    if (res.isOk && res.body is List) {
      return (res.body as List)
          .map((e) => Finance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
  Future<List<Owner>> getOwners() async {
    final res = await api.owners();
    if (res.isOk && res.body is List) {
      return (res.body as List)
          .map((e) => Owner.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

}