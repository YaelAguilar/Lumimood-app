import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final http.Client _client;
  final SharedPreferences _sharedPreferences;

  ApiClient(this._client, this._sharedPreferences);

  String? get _token => _sharedPreferences.getString('jwt_token');

  Future<Map<String, String>> _getHeaders([Map<String, String>? additionalHeaders]) async {
    final token = _token;
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    // Agregar headers adicionales si se proporcionan
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  Future<http.Response> get(String url, [Map<String, String>? additionalHeaders]) async {
    final headers = await _getHeaders(additionalHeaders);
    return _client.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, Map<String, dynamic> body, [Map<String, String>? additionalHeaders]) async {
    final headers = await _getHeaders(additionalHeaders);
    return _client.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  Future<http.Response> put(String url, Map<String, dynamic> body, [Map<String, String>? additionalHeaders]) async {
    final headers = await _getHeaders(additionalHeaders);
    return _client.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  Future<http.Response> delete(String url, [Map<String, String>? additionalHeaders]) async {
    final headers = await _getHeaders(additionalHeaders);
    return _client.delete(Uri.parse(url), headers: headers);
  }
}