import 'package:flutter_boilerplate/util/app_constants.dart';

class Endpoints {
  static const login = '${AppConstants.baseUrl}/api/auth/login';
  static const logout = '${AppConstants.baseUrl}/api/auth/logout';
  static const me = '${AppConstants.baseUrl}/api/auth/me';
  static const refresh = '${AppConstants.baseUrl}/api/auth/refresh';
  static const orders = '${AppConstants.baseUrl}/api/orders';
  static String order(int id) => '${AppConstants.baseUrl}/api/orders/$id';
  static String assignOrder(int id) => '${AppConstants.baseUrl}/api/orders/$id/assign';
  static String completeOrder(int id) => '${AppConstants.baseUrl}/api/orders/$id/complete';

  static const orderItems = '${AppConstants.baseUrl}/api/order_items';
  static String itemsOfOrder(int orderId) => '${AppConstants.baseUrl}/api/order_items/$orderId';
  static String orderItem(int orderId, int id) => '${AppConstants.baseUrl}/api/order_items/$orderId/$id';

  static const payments = '${AppConstants.baseUrl}/api/payments';

  static String wallet(int userId) => '${AppConstants.baseUrl}/api/wallet/$userId';
  static String walletTransactions(int userId) => '${AppConstants.baseUrl}/api/wallet/$userId/transactions';

  static const assistants = '${AppConstants.baseUrl}/api/assistants';

  static const history = '${AppConstants.baseUrl}/api/history';
  static String historyByEntityId(String entity, int id) => '${AppConstants.baseUrl}/api/history/$entity/$id';
  static String historyByEntity(String entity) => '${AppConstants.baseUrl}/api/history/$entity';

  static const analyticsDashboard = '${AppConstants.baseUrl}/api/analytics/dashboard';
  static const analyticsReports = '${AppConstants.baseUrl}/api/analytics/reports';
}
