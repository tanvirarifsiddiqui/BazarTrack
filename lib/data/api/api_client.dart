import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

import 'package:flutter_boilerplate/data/model/response/error_response.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;

class ApiClient extends GetxService {
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  late String token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token) ?? '';
    debugPrint('Token: $token');
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }

  Uri _getUri(String uri) {
    return uri.startsWith('http') ? Uri.parse(uri) : Uri.parse(AppConstants.baseUrl + uri);
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nToken: $token');
      http.Response response0 = await http.get(
        _getUri(uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(response0);
      debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nToken: $token');
      debugPrint('====> API Body: $body');
      debugPrint('====> API Json Body: ${jsonEncode(body)}');
      http.Response response0 = await http.post(
        _getUri(uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(response0);
      debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nToken: $token');
      debugPrint('====> API Body: $body');
      http.MultipartRequest request = http.MultipartRequest('POST', _getUri(uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          if(foundation.kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            http.MultipartFile part = http.MultipartFile(
              multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
              filename: basename(multipart.file!.path), contentType: MediaType('image', 'jpg'),
            );
            request.files.add(part);
          }else {
            File file = File(multipart.file!.path);
            request.files.add(http.MultipartFile(
              multipart.key, file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last,
            ));
          }
        }
      }
      request.fields.addAll(body);
      http.Response response0 = await http.Response.fromStream(await request.send());
      Response response = handleResponse(response0);
      debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nToken: $token');
      debugPrint('====> API Body: $body');
      http.Response response0 = await http.put(
        _getUri(uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(response0);
      debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Call: $uri\nToken: $token');
      http.Response response0 = await http.delete(
        _getUri(uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(response0);
      debugPrint('====> API Response: [${response.statusCode}] $uri\n${response.body}');
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  Response handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      debugPrint('JSON decode failed: $e');
      decoded = null;
    }

    // If API uses wrapper { error, msg, data: ... } prefer data as actual body
    dynamic mainBody;
    if (decoded is Map && decoded.containsKey('data')) {
      mainBody = decoded['data'];
    } else {
      mainBody = decoded ?? response.body;
    }

    Response response0 = Response(
      body: mainBody,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200) {
      if (decoded is Map) {
        // Prefer msg -> message -> error -> errors[0].message
        final dynamic msg = decoded['msg'] ?? decoded['message'] ?? decoded['error'];
        if (msg != null) {
          response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            bodyString: response0.bodyString,
            headers: response0.headers,
            statusText: msg.toString(),
          );
        } else if (decoded['errors'] != null) {
          try {
            final errors = decoded['errors'];
            if (errors is List && errors.isNotEmpty) {
              final first = errors[0];
              final message = (first is Map && first.containsKey('message')) ? first['message'] : first.toString();
              response0 = Response(
                statusCode: response0.statusCode,
                body: response0.body,
                bodyString: response0.bodyString,
                headers: response0.headers,
                statusText: message.toString(),
              );
            }
          } catch (_) {}
        }
      } else if (mainBody == null) {
        // No body and non-200 => likely connectivity
        response0 = Response(statusCode: 0, statusText: noInternetMessage);
      }
    } else {
      // status == 200: set statusText to msg if present (useful for UX)
      if (decoded is Map && decoded['msg'] != null) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          bodyString: response0.bodyString,
          headers: response0.headers,
          statusText: decoded['msg'].toString(),
        );
      }
    }

    return response0;
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}
