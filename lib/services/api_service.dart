// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator 對應本機
  static const _baseUrl = 'http://10.0.2.2:8000';

  /// 註冊 API 呼叫（對應 /api/auth/register）
  static Future<bool> register(
    String username,
    String password,
    String language,
    String identity,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/auth/register');
    try {
      print('POST ➡️ $uri');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
              'language': language,
              'identity': identity,
            }),
          )
          .timeout(const Duration(seconds: 5));

      print('RESP ➡️ ${response.statusCode}: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['status'] == 'success';
    } catch (e) {
      print('❌ 註冊錯誤：$e');
      return false;
    }
  }

  /// 登入 API 呼叫（對應 /api/auth/login）
  static Future<bool> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');
    try {
      print('POST ➡️ $uri');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      print('RESP ➡️ ${response.statusCode}: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['status'] == 'success';
    } catch (e) {
      print('❌ 登入錯誤：$e');
      return false;
    }
  }
}
