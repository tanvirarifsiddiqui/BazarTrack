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
import 'package:flutter_boilerplate/features/finance/controller/finance_controller.dart';

import 'package:flutter_boilerplate/features/finance/repository/assistant_finance_repo.dart';
import 'package:flutter_boilerplate/features/finance/repository/finance_repo.dart';

import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:flutter_boilerplate/features/history/repository/history_repo.dart';
import 'package:flutter_boilerplate/features/history/controller/history_controller.dart';

import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:flutter_boilerplate/data/model/response/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../features/dashboard/controller/analytics_controller.dart';
import '../features/dashboard/repository/analytics_repo.dart';
import '../features/finance/controller/assistant_finance_controller.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences,fenix: true);
  Get.lazyPut(() => ApiClient(sharedPreferences: Get.find<SharedPreferences>()));
  Get.lazyPut(() => BazarTrackApi(client: Get.find<ApiClient>()));

  // Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find<SharedPreferences>(), apiClient: Get.find<ApiClient>()));
  Get.lazyPut(() => AuthRepo(api: Get.find<BazarTrackApi>(), sharedPreferences: Get.find<SharedPreferences>()));
  Get.lazyPut(() => LanguageRepo());
  // Get.lazyPut(() => AdvanceRepo(sharedPreferences: Get.find<SharedPreferences>()));
  Get.lazyPut(() => OrderRepo(api: Get.find<BazarTrackApi>()),fenix: true);
  Get.lazyPut(() => HistoryRepo(api: Get.find<BazarTrackApi>()),fenix: true);
  Get.lazyPut(() => FinanceRepo(api: Get.find<BazarTrackApi>()),fenix: true);
  Get.lazyPut(() => AssistantFinanceRepo(api: Get.find<BazarTrackApi>()),fenix: true);
  Get.lazyPut(() => AnalyticsRepo(api: Get.find<BazarTrackApi>()),fenix: true);



  // Services
  Get.put(AuthService(authRepo: Get.find<AuthRepo>()),permanent: true);
  // Get.put(AdvanceService(advanceRepo: Get.find()), permanent: true);
  // Get.put(OrderService(orderRepo: Get.find<OrderRepo>()), permanent: true);
  // Get.put(HistoryService(historyRepo: Get.find<HistoryRepo>()),);
  // Get.put(FinanceService(repo: Get.find<FinanceRepo>()));
  // Get.put(AssistantFinanceService(repo: Get.find<AssistantFinanceRepo>()));
  // Get.put(AnalyticsService(repo: Get.find<AnalyticsRepo>()),);

  // Controllers
  Get.lazyPut(() => AuthController(authService: Get.find<AuthService>(), authRepo: Get.find<AuthRepo>()), fenix: true);
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find<SharedPreferences>()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  // Get.lazyPut(() => AdvanceController(advanceService: Get.find()), fenix: true);
  Get.lazyPut(() => OrderController(orderRepo: Get.find<OrderRepo>(), authService: Get.find<AuthService>(),financeRepo: Get.find<FinanceRepo>()), fenix: true);
  Get.lazyPut(() => HistoryController(historyRepo: Get.find<HistoryRepo>()), fenix: true);
  Get.lazyPut(() => FinanceController(financeRepo: Get.find<FinanceRepo>()), fenix: true);
  Get.lazyPut(() => AssistantFinanceController(repo: Get.find<AssistantFinanceRepo>(), auth: Get.find<AuthService>()), fenix: true);
  Get.lazyPut(() => AnalyticsController(analyticsRepo: Get.find(), orderRepo: Get.find()), fenix: true);

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
