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

  /// Remove the saved token from [SharedPreferences].
  Future<void> logout() async {
    await sharedPreferences.remove(AppConstants.token);
  }

  /// Whether a token already exists in storage.
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }
}
