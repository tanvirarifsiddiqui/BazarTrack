import 'package:flutter_boilerplate/data/api/api_client.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  /// Save a dummy token locally to simulate a successful login.
  Future<void> saveLogin() async {
    const token = 'dummy_token';
    apiClient.updateHeader(token);
    await sharedPreferences.setString(AppConstants.token, token);
  }

  Future<void> signUp(String userJson) async {
    await saveLogin();
    await saveUser(userJson);
  }

  Future<void> saveUser(String userJson) async {
    await sharedPreferences.setString(AppConstants.userData, userJson);
  }

  String? getUser() {
    return sharedPreferences.getString(AppConstants.userData);
  }

  /// Remove the saved token from [SharedPreferences].
  Future<void> logout() async {
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.remove(AppConstants.userData);
  }

  /// Whether a token already exists in storage.
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }
}
