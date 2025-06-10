class Endpoints {
  static const login = '/api/auth/login';
  static const logout = '/api/auth/logout';
  static const me = '/api/auth/me';
  static const refresh = '/api/auth/refresh';

  static const orders = '/api/orders';
  static String order(int id) => '/api/orders/\$id';
  static String assignOrder(int id) => '/api/orders/\$id/assign';
  static String completeOrder(int id) => '/api/orders/\$id/complete';

  static const orderItems = '/api/order_items';
  static String itemsOfOrder(int orderId) => '/api/order_items/\$orderId';
  static String orderItem(int orderId, int id) => '/api/order_items/\$orderId/\$id';

  static const payments = '/api/payments';

  static String wallet(int userId) => '/api/wallet/\$userId';
  static String walletTransactions(int userId) => '/api/wallet/\$userId/transactions';

  static const history = '/api/history';
  static String historyByEntity(String entity, int id) => '/api/history/\$entity/\$id';

  static const analyticsDashboard = '/api/analytics/dashboard';
  static const analyticsReports = '/api/analytics/reports';
}
