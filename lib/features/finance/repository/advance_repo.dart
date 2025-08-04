import 'dart:convert';

import 'package:flutter_boilerplate/features/finance/model/advance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvanceRepo {
  final SharedPreferences sharedPreferences;
  static const String _key = 'advance_list';

  AdvanceRepo({required this.sharedPreferences});

  List<Advance> getAdvances() {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Advance.fromJson(e)).toList();
  }

  Future<void> saveAdvances(List<Advance> advances) async {
    final jsonString = jsonEncode(advances.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_key, jsonString);
  }
}
