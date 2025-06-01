// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';
import '../models/message.dart';
import 'package:flutter/material.dart';

class ApiService {
  // Android emulator 對應本機
  static const _baseUrl = 'http://10.0.2.2:8000';

  static String globalUsername = '';

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
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      print('RESP ➡️ ${response.statusCode}: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        final token = data['access_token'];
        await TokenService.saveToken(token);
        await TokenService.saveUsername(username);
        globalUsername = username; // 儲存全域使用者名稱
        print('✅ Token 已儲存：$token');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ 登入錯誤：$e');
      return false;
    }
  }

  // 取得聊天室列表 API 呼叫（對應 /api/chat/get_chatrooms）
  static Future<Map<String, dynamic>> getChatrooms() async {
    final uri = Uri.parse('$_baseUrl/api/chat/get_chatrooms');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'username': globalUsername}),
      );

      if (response.statusCode == 200) {
        print('RESP ➡️ ${response.statusCode}: ${response.body}');
        final data = json.decode(response.body);
        return {
          'chatrooms': data['chatrooms'] as List<dynamic>,
          'language': data['language'],
        };
      } else {
        SnackBar(
          content: Text('❌ 取得聊天室失敗: ${response.statusCode} ${response.body}'),
        );
        return {'chatrooms': [], 'language': ''};
      }
    } catch (e) {
      SnackBar(content: Text('❌ API 呼叫錯誤: $e'));
      return {'chatrooms': [], 'language': ''};
    }
  }

  /// 建立聊天室 API 呼叫（對應 /api/chat/create_chatroom）
  static Future<Map<String, dynamic>> createChatroom(
    String user1,
    String user2,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/chat/create_chatroom');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_1': user1, 'user_2': user2}),
          )
          .timeout(const Duration(seconds: 5));

      print('RESP ➡️ ${response.statusCode}: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'status': 'failure', 'message': 'HTTP Error'};
      }

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('❌ 建立聊天室錯誤：$e');
      return {'status': 'failure', 'message': 'Exception: $e'};
    }
  }

  // 取得訊息 API 呼叫（對應 /api/chat/get_messages）
  static Future<List<Message>> fetchMessages({
    required String username,
    required String chatroomId,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/chat/get_messages');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'chatroom_id': chatroomId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final List<dynamic> messagesData = responseData['messages'];

        return messagesData
            .map<Message>(
              (msg) => Message(
                sender: msg['sender_name'],
                receiver: msg['receiver_name'],
                chatroomId: chatroomId,
                text:
                    msg['sender_name'] == username
                        ? msg['text_sender']
                        : msg['text_reciever'],
                specializedTerms: [],
                timestamp: DateTime.parse(msg['timestamp']),
                isMe: msg['sender_name'] == username,
              ),
            )
            .toList();
      } else {
        print('Fetch failed: ${responseData['message']}');
        return [];
      }
    } catch (e) {
      print('Fetch messages error: $e');
      return [];
    }
  }
}
