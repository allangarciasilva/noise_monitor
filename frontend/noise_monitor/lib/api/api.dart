import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:noise_monitor/models/device.dart';
import 'package:noise_monitor/models/user.dart';
import 'package:noise_monitor/gen/api_host.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiError implements Error {
  late String errorMessage;

  static String _createErrorMessage(dynamic responseBody) {
    if (responseBody is Map<String, dynamic> &&
        responseBody.containsKey('detail') &&
        responseBody['detail'] is String) {
      return responseBody['detail'];
    } else {
      debugPrint("An API error ocurred. Response body: $responseBody.");
      return 'Internal Server Error';
    }
  }

  ApiError(dynamic responseBody) {
    errorMessage = _createErrorMessage(responseBody);
  }

  @override
  String toString() {
    return errorMessage;
  }

  @override
  StackTrace? get stackTrace => StackTrace.current;
}

User? _currentUser;

bool _responseOk(http.Response response) {
  return response.statusCode / 100 == 2;
}

Uri _renderHttpUri(String route, {Map<String, String>? query}) {
  if (API_HOST.contains("ngrok.io")) {
    return Uri.https(API_HOST, route, query);
  }
  return Uri.http("$API_HOST:$API_PORT", route, query);
}

Uri _renderWsUrl(String route, {Map<String, String>? query}) {
  int? port = null;
  if (!API_HOST.contains("ngrok.io")) {
    port = API_PORT;
  }

  return Uri(
    scheme: "ws",
    host: API_HOST,
    port: port,
    path: route,
    queryParameters: query,
  );
}

Map<String, String> _getHeaders() {
  final headers = {'Content-Type': 'application/json'};
  if (_currentUser != null) {
    headers['X-Api-Token'] = _currentUser!.token;
  }
  return headers;
}

dynamic _getVerifiedBody(http.Response response) {
  final body = jsonDecode(response.body);
  if (!_responseOk(response)) {
    throw ApiError(body);
  }
  return body;
}

Future<dynamic> get(String route, {Map<String, String>? query}) async {
  final response = await http.get(
    _renderHttpUri(route, query: query),
    headers: _getHeaders(),
  );

  return _getVerifiedBody(response);
}

Future<dynamic> delete(String route, {Map<String, String>? query}) async {
  final response = await http.delete(
    _renderHttpUri(route, query: query),
    headers: _getHeaders(),
  );

  return _getVerifiedBody(response);
}

Future<dynamic> post(
  String route, {
  Map<String, String>? query,
  String? body,
}) async {
  final response = await http.post(
    _renderHttpUri(route, query: query),
    headers: _getHeaders(),
    body: body,
  );

  return _getVerifiedBody(response);
}

Future<User> login(String email, String password) async {
  final body = await post(
    "/auth/login/",
    body: jsonEncode({"email": email, "password": password}),
  );

  _currentUser = User.fromJson(body);
  return _currentUser!;
}

void logout() {
  _currentUser = null;
}

Future<List<Device>> getRoomDevices(int roomId) async {
  final body = await get("/rooms/$roomId/");
  final res = (body as List<dynamic>).map((e) => Device.fromJson(e)).toList();
  return res;
}

WebSocketChannel connectToWebsocket(
  String route, {
  Map<String, String>? query,
}) {
  if (_currentUser != null) {
    query = query ?? {};
    query["token"] = _currentUser!.token;
  }
  final uri = _renderWsUrl(route, query: query);
  print(uri);
  return WebSocketChannel.connect(uri);
}
