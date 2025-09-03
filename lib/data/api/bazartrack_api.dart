import 'package:flutter_boilerplate/data/api/api_client.dart';
import 'package:flutter_boilerplate/data/api/endpoints.dart';
import 'package:get/get.dart';

class BazarTrackApi {
  final ApiClient client;
  BazarTrackApi({required this.client});

  Future<Response> login(String email, String password) async {
    final res = await client.postData(Endpoints.login, {
      'email': email,
      'password': password,
    });
    if (res.isOk && res.body is Map && res.body['token'] != null) {
      client.updateHeader(res.body['token']);
    }
    return res;
  }

  //Auth
  Future<Response> logout() => client.postData(Endpoints.logout, {});
  Future<Response> me() => client.getData(Endpoints.me);
  Future<Response> refresh() => client.postData(Endpoints.refresh, {});
  Future<Response> createUser(Map<String, dynamic> data) => client.postData(Endpoints.createUser, data);
  Future<Response> updatePassword(Map<String, dynamic> data) => client.putData(Endpoints.password, data);

  Future<Response> orders({String? status, int? ownerId, int? limit, int? cursor, int? assignedTo, bool unassigned = false,}) {
    final query = <String, dynamic>{};
    if (status     != null) query['status']      = status;
    if (ownerId    != null) query['owner_id']    = ownerId;
    if (limit      != null) query['limit']       = limit;
    if (cursor     != null) query['cursor']      = cursor;
    // Explicit unassigned mode (assigned_to=null)
    if (unassigned) {
      query['assigned_to'] = 'null';
    } else if (assignedTo != null) {
      query['assigned_to'] = assignedTo;
    }
    return client.getData(Endpoints.orders, query: query.isEmpty ? null : query);
  }

  Future<Response> createOrder(Map<String, dynamic> data) => client.postData(Endpoints.orders, data);
  Future<Response> order(int id) => client.getData(Endpoints.order(id));
  Future<Response> updateOrder(int id, Map<String, dynamic> data) => client.putData(Endpoints.order(id), data);
  Future<Response> deleteOrder(int id) => client.deleteData(Endpoints.order(id));
  Future<Response> assignOrder(int id, Map<String, dynamic> data) => client.postData(Endpoints.assignOrder(id), data);
  Future<Response> completeOrder(int id, Map<String, dynamic> data) => client.postData(Endpoints.completeOrder(id), data);

  // Order items
  Future<Response> orderItems() => client.getData(Endpoints.orderItems);
  Future<Response> itemsOfOrder(int orderId) => client.getData(Endpoints.itemsOfOrder(orderId));
  Future<Response> orderItem(int orderId, int id) => client.getData(Endpoints.orderItem(orderId, id));
  Future<Response> createItem(Map<String, dynamic> data) => client.postData(Endpoints.orderItems, data);
  Future<Response> updateItem(int orderId, int id, Map<String, dynamic> data) => client.putData(Endpoints.orderItem(orderId, id), data);
  Future<Response> deleteItem(int orderId, int id) => client.deleteData(Endpoints.orderItem(orderId, id));

  // Payments
  Future<Response> payments({Map<String, dynamic>? query}) => client.getData(Endpoints.payments, query: query);
  Future<Response> createPayment(Map<String, dynamic> data) => client.postData(Endpoints.payments, data);

  // Wallet
  Future<Response> wallet(int userId) => client.getData(Endpoints.wallet(userId));
  Future<Response> walletTransactions(int userId, Map<String, dynamic>? query) => client.getData(Endpoints.walletTransactions(userId), query: query);

  // Assistants
  Future<Response> assistants({bool withBalance = false}) {
    final uri = Endpoints.assistants + (withBalance ? '/?with_balance=true' : '');
    return client.getData(uri);
  }
  // Owners
  Future<Response> owners() => client.getData(Endpoints.owners);

  // History
  Future<Response> history({Map<String, dynamic>? query}) => client.getData(Endpoints.history,query: query);
  Future<Response> historyByEntityId(String entity, int id) => client.getData(Endpoints.historyByEntityId(entity, id));
  Future<Response> historyByEntity(String entity,{Map<String, dynamic>? query}) => client.getData(Endpoints.historyByEntity(entity),query: query);
  Future<Response> createHistory(Map<String, dynamic> data) => client.postData(Endpoints.history, data);
  Future<Response> deleteHistory(int id) => client.deleteData('${Endpoints.history}/$id');

  // Analytics
  Future<Response> dashboard() => client.getData(Endpoints.analyticsDashboard);
  Future<Response> reports() => client.getData(Endpoints.analyticsReports);
  Future<Response> assistantAnalytics(int id) => client.getData(Endpoints.assistantAnalytics(id));
  Future<Response> assistantSelfAnalytics() => client.getData(Endpoints.assistantSelfAnalytics());
}
