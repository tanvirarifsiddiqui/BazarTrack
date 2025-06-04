import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:flutter_boilerplate/features/finance/advance_screen.dart';
import 'package:flutter_boilerplate/features/auth/signup_screen.dart';
import 'package:flutter_boilerplate/features/splash/splash_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String signUp = '/signup';
  static const String ownerDashboard = '/owner';
  static const String assistantDashboard = '/assistant';
  static const String advance = '/advance';

  static getInitialRoute() => initial;
  static getSplashRoute() => splash;
  static getHomeRoute(String name) => '$home?name=$name';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => SplashScreen()),
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: ownerDashboard, page: () => const OwnerDashboard()),
    GetPage(name: assistantDashboard, page: () => const AssistantDashboard()),
    GetPage(name: advance, page: () => const AdvanceScreen()),
  ];
}