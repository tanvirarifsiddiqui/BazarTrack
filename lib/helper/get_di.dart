import 'dart:convert';

import 'package:flutter_boilerplate/controller/language_controller.dart';
import 'package:flutter_boilerplate/controller/localization_controller.dart';
import 'package:flutter_boilerplate/controller/splash_controller.dart';
import 'package:flutter_boilerplate/controller/theme_controller.dart';
import 'package:flutter_boilerplate/data/repository/language_repo.dart';
import 'package:flutter_boilerplate/data/repository/splash_repo.dart';
import 'package:flutter_boilerplate/data/api/api_client.dart';
import 'package:flutter_boilerplate/data/api/bazartrack_api.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/finance/controller/assistant_finance_controller.dart';
import 'package:flutter_boilerplate/features/finance/controller/finance_controller.dart';

import 'package:flutter_boilerplate/features/finance/repository/advance_repo.dart';
import 'package:flutter_boilerplate/features/finance/controller/advance_controller.dart';
import 'package:flutter_boilerplate/features/finance/repository/assistant_finance_repo.dart';
import 'package:flutter_boilerplate/features/finance/repository/finance_repo.dart';
import 'package:flutter_boilerplate/features/finance/service/advance_service.dart';
import 'package:flutter_boilerplate/features/finance/service/finance_service.dart';

import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:flutter_boilerplate/features/orders/service/order_service.dart';
import 'package:flutter_boilerplate/features/history/repository/history_repo.dart';
import 'package:flutter_boilerplate/features/history/controller/history_controller.dart';
import 'package:flutter_boilerplate/features/history/service/history_service.dart';

import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:flutter_boilerplate/data/model/response/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../features/finance/service/assistant_finance_service.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(sharedPreferences: Get.find()));
  Get.lazyPut(() => BazarTrackApi(client: Get.find()));

  // Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(() => AuthRepo(api: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AdvanceRepo(sharedPreferences: Get.find()));
  Get.lazyPut(() => OrderRepo(api: Get.find()));
  Get.lazyPut(() => HistoryRepo(api: Get.find()));
  Get.lazyPut(() => FinanceRepo(api: Get.find()));
  Get.lazyPut(() => AssistantFinanceRepo(api: Get.find()));


  // Services
  Get.put(AuthService(authRepo: Get.find()),permanent: true);
  Get.put(AdvanceService(advanceRepo: Get.find()), permanent: true);
  Get.put(OrderService(orderRepo: Get.find()), permanent: true);
  Get.put(HistoryService(historyRepo: Get.find()), permanent: true);
  Get.put(FinanceService(repo: Get.find()));
  Get.put(AssistantFinanceService(repo: Get.find()));

  // Controllers
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthController(authService: Get.find()), fenix: true);
  Get.lazyPut(() => AdvanceController(advanceService: Get.find()), fenix: true);
  Get.lazyPut(() => OrderController(orderService: Get.find()), fenix: true);
  Get.lazyPut(() => HistoryController(historyService: Get.find()), fenix: true);
  Get.lazyPut(() => FinanceController(service: Get.find()), fenix: true);
  Get.lazyPut(() => AssistantFinanceController(service: Get.find(), auth: Get.find(),), fenix: true);


  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    Map<String, String> jsonData = {};
    mappedJson.forEach((key, value) {
      jsonData[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonData;
  }
  return languages;
}
