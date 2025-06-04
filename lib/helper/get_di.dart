import 'dart:convert';

import 'package:flutter_boilerplate/controller/language_controller.dart';
import 'package:flutter_boilerplate/controller/localization_controller.dart';
import 'package:flutter_boilerplate/controller/splash_controller.dart';
import 'package:flutter_boilerplate/controller/theme_controller.dart';
import 'package:flutter_boilerplate/data/repository/language_repo.dart';
import 'package:flutter_boilerplate/data/repository/splash_repo.dart';
import 'package:flutter_boilerplate/data/api/api_client.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';

import 'package:flutter_boilerplate/features/finance/repository/advance_repo.dart';
import 'package:flutter_boilerplate/features/finance/controller/advance_controller.dart';

import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/repository/order_repo.dart';
import 'package:flutter_boilerplate/features/history/repository/history_repo.dart';
import 'package:flutter_boilerplate/features/history/controller/history_controller.dart';

import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:flutter_boilerplate/data/model/response/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  // Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));

  Get.lazyPut(() => AdvanceRepo(sharedPreferences: Get.find()));

  Get.lazyPut(() => OrderRepo());
  Get.lazyPut(() => HistoryRepo(sharedPreferences: Get.find()));


  // Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => AdvanceController(advanceRepo: Get.find()));
  Get.lazyPut(() => OrderController(orderRepo: Get.find()));
  Get.lazyPut(() => HistoryController(historyRepo: Get.find()));


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
