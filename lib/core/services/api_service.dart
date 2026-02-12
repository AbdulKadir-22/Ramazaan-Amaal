import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class ApiService {
  Future<Map<String, dynamic>?> registerDevice({
    required String name,
    required String token,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.registerDevice);
      final body = jsonEncode({
        "name": name,
        "token": token,
        "language": "en",
      });
      
      debugPrint('DEBUG: Registering device at $url');
      debugPrint('DEBUG: Request Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));

      debugPrint('DEBUG: Registration Status: ${response.statusCode}');
      debugPrint('DEBUG: Registration Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      rethrow; // Pass error back to UI to show Snackbar
    }
  }

  Future<Map<String, dynamic>?> sendBroadcastNotification({
    required String title,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendNotification),
        headers: {
          'Content-Type': 'application/json',
          'x-admin-key': ApiConstants.adminKey,
        },
        body: jsonEncode({
          "title": title,
          "message": message,
        }),
      );

      debugPrint('DEBUG: Send Notification Status: ${response.statusCode}');
      debugPrint('DEBUG: Send Notification Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send broadcast: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}