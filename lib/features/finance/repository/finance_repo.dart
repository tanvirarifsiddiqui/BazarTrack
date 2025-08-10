/*
// Title: Finance Repository
// Description: This is the Finance Repository for getting finance related data.
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 04:24 PM
*/

import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import '../model/finance.dart';

class FinanceRepo {
  final BazarTrackApi api;
  FinanceRepo({ required this.api });

  // GET /api/payments
  Future<List<Finance>> payments() async {
    final res = await api.payments();
    if (res.isOk && res.body is List) {
      return (res.body as List)
          .map((e) => Finance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // POST /api/payments
  Future<Finance> createPayment(Finance f) async {
    final res = await api.createPayment(f.toJsonForCreate());
    if (res.isOk && res.body is Map<String, dynamic>) {
      return Finance.fromJson(res.body as Map<String, dynamic>);
    }
    throw Exception('Failed to record payment (${res.statusCode})');
  }
}


