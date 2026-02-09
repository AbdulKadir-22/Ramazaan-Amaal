import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  Future<Map<String, dynamic>?> registerDevice({
    required String name,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerDevice),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "token": token,
          "language": "en", // Hardcoded as requested
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      rethrow; // Pass error back to UI to show Snackbar
    }
  }
}