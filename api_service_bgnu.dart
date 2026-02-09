// lib/services/api_service_bgnu.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceBGNU {
  static const String baseUrl = "https://bgnu.space/api/";

  /// GET BGNU students
  static Future<List<dynamic>> getStudents() async {
    final url = Uri.parse("${baseUrl}student_data");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['status'] == true && decoded['data'] != null) {
        return decoded['data'];
      } else {
        throw Exception("No students found");
      }
    } else {
      throw Exception("Failed to fetch students: ${response.statusCode}");
    }
  }
}