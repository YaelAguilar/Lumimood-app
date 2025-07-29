import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class ApiClient {
  final http.Client _client;
  final SharedPreferences _sharedPreferences;

  ApiClient(this._client, this._sharedPreferences);

  String? get _token => _sharedPreferences.getString('jwt_token');

Future<Map<String, String>> _getHeaders() async {
  final token = _token;
  
  // DEBUGGING: Agregar más logs para verificar el token
  log('🔍 API CLIENT DEBUG: Token exists: ${token != null}');
  if (token != null) {
    log('🔍 API CLIENT DEBUG: Token length: ${token.length}');
    log('🔍 API CLIENT DEBUG: Token first 20 chars: ${token.substring(0, math.min(20, token.length))}...');
  } else {
    log('❌ API CLIENT DEBUG: NO TOKEN FOUND in SharedPreferences');
    
    // Verificar todas las claves en SharedPreferences
    final keys = _sharedPreferences.getKeys();
    log('🔍 API CLIENT DEBUG: Available keys in SharedPreferences: $keys');
  }
  
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  log('🔍 API CLIENT DEBUG: Final headers: ${headers.keys.toList()}');
  return headers;
}

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    log('🌐 API GET: $url');
    log('🔍 Headers: $headers');
    
    final response = await _client.get(Uri.parse(url), headers: headers);
    log('📊 Response status: ${response.statusCode}');
    
    return response;
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    log('🌐 API POST: $url');
    log('🔍 Headers: $headers');
    log('📝 Body: $body');
    
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    log('📊 Response status: ${response.statusCode}');
    
    return response;
  }

  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    log('🌐 API PUT: $url');
    log('🔍 Headers: $headers');
    
    final response = await _client.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    log('📊 Response status: ${response.statusCode}');
    
    return response;
  }

  Future<http.Response> delete(String url) async {
    final headers = await _getHeaders();
    log('🌐 API DELETE: $url');
    log('🔍 Headers: $headers');
    
    final response = await _client.delete(Uri.parse(url), headers: headers);
    log('📊 Response status: ${response.statusCode}');
    
    return response;
  }
}