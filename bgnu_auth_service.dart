import 'dart:convert';
import 'package:http/http.dart' as http;

class BgnuAuthService {
  static const String url =
      "https://bgnu.space/api/submit_login";

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        return {
          "success": true,
          "user": data['data'], // student info
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Login failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error",
      };
    }
  }
}