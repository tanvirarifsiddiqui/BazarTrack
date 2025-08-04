import 'dart:convert';

import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepo {
  final SharedPreferences sharedPreferences;
  static const String _key = 'history_logs';

  HistoryRepo({required this.sharedPreferences});

  List<HistoryLog> getLogs() {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => HistoryLog.fromJson(e)).toList();
  }

  Future<void> saveLogs(List<HistoryLog> logs) async {
    final jsonString = jsonEncode(logs.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_key, jsonString);
  }
}
