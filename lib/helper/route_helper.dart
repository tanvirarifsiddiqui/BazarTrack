import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:flutter_boilerplate/features/finance/advance_screen.dart';
import 'package:flutter_boilerplate/features/auth/signup_screen.dart';
import 'package:flutter_boilerplate/features/history/history_view_page.dart';
import 'package:flutter_boilerplate/features/orders/create_order_screen.dart';
import 'package:flutter_boilerplate/features/profile/profile_screen.dart';
import 'package:flutter_boilerplate/features/splash/splash_screen.dart';
import 'package:flutter_boilerplate/features/orders/order_list_screen.dart';
import 'package:flutter_boilerplate/features/orders/order_detail_screen.dart';
import 'package:get/get.dart';

import '../features/history/entity_history_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String signUp = '/signup';
  static const String ownerDashboard = '/owner';
  static const String assistantDashboard = '/assistant';
  static const String profile = '/profile';
  static const String advance = '/advance';
  static const String orders = '/orders';
  static const String orderDetail = '/order';
  static const String entityHistory = '/entityHistory';
  // modification
  static const String orderCreate = '/orders/create';


  static getInitialRoute() => initial;
  static getSplashRoute() => splash;
  static getHomeRoute(String name) => '$home?name=$name';
  static String getOrdersRoute() => orders;
  static String getOrderDetailRoute(String id) => '$orderDetail?id=$id';
  static String getOrderHistoryRoute(String type, String id) => '$entityHistory?type=$type&id=$id';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: ownerDashboard, page: () => const OwnerDashboard()),
    GetPage(name: assistantDashboard, page: () =>  AssistantDashboard()),
    GetPage(name: advance, page: () => const AdvanceScreen()),
    GetPage(name: orders, page: () => const OrderListScreen()),
    GetPage(name: orderCreate, page: () => CreateOrderScreen()),
    GetPage(
      name: orderDetail,
      page: () => OrderDetailScreen(orderId: Get.parameters['id']!),
    ),
    GetPage(
      name: entityHistory,
      // page: () => EntityHistoryScreen(
      //   entityType: Get.parameters['type']!,
      //   entityId: Get.parameters['id']!,
      // ),
      page: () => HistoryViewPage(
        entity: Get.parameters['type']!,
        entityId: int.parse(Get.parameters['id']!),
      ),
    ),
  ];
}