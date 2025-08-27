import 'dart:convert';

import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../model/user.dart';
class AuthRepo {
  final BazarTrackApi api;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.api, required this.sharedPreferences});

  Future<Response> login(String email, String password) async {
    final response = await api.login(email, password);
    if (response.isOk && response.body is Map) {
      final token = response.body['token'];
      if (token != null) {
        await sharedPreferences.setString(AppConstants.token, token);
      }
      await sharedPreferences.setString(AppConstants.userData, jsonEncode(response.body['user']));
    }
    return response;
  }

  Future<UserModel> createUser({required String name, required String email, required String password, required String role,}) async {
    final body = {
      'name':     name,
      'email':    email,
      'password': password,
      'role':     role,
    };

    final res = await api.createUser(body);
    if (!res.isOk || res.body is! Map<String, dynamic> || res.statusCode == 409) {
      final msg = res.body is Map
          ? (res.body['msg'] ?? 'Unknown error').toString()
          : 'Email already exists';
      throw Exception(msg);
    }
    if (!res.isOk || res.body is! Map<String, dynamic>) {
      final msg = res.body is Map
          ? (res.body['msg'] ?? 'Unknown error').toString()
          : 'Failed to create user';
      throw Exception(msg);
    }

    final user = UserModel.fromJson(res.body as Map<String, dynamic>);

    return user;
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
