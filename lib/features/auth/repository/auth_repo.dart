import 'package:flutter_boilerplate/data/api/api_client.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient})

  String login() {
    String token = '';
    apiClient.updateHeader(token);
    sharedPreferences.setString(AppConstants.token, token);
    return apiClient.getData(AppConstants.loginUri)['abc'];
  }
}