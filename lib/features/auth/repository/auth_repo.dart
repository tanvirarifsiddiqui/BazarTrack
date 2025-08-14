import 'dart:convert';

import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class AuthRepo {
  final BazarTrackApi api;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.api, required this.sharedPreferences});

  Future<Response> login(String email, String password) async {
    final response = await api.login(email, password);
    if (response.isOk && response.body is Map) {
      final token = await response.body['data']['token'];
      if (token != null) {
        await sharedPreferences.setString(AppConstants.token, token);
      }
      await sharedPreferences.setString(AppConstants.userData, jsonEncode(response.body['data']['user']));
    }
    return response;
  }

  Future<void> signUp(String userJson) async {
    await sharedPreferences.setString(AppConstants.userData, userJson);
  }

  Future<void> saveUser(String userJson) async {
    await sharedPreferences.setString(AppConstants.userData, userJson);
  }

  Future<void> logout() async {
    await api.logout();
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.remove(AppConstants.userData);
  }

  String? getUser() => sharedPreferences.getString(AppConstants.userData);

  bool isLoggedIn() => sharedPreferences.containsKey(AppConstants.token);
}
