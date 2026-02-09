import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://hackdefenders.com/api/";

  /// Generic POST request (form-urlencoded)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        body: body,
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON: $e'};
        }
      } else {
        return {
          'success': false,
          'message': 'POST request failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST request with JSON body
  static Future<Map<String, dynamic>> postJson(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(baseUrl + endpoint);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON: $e'};
        }
      } else {
        return {
          'success': false,
          'message': 'POST JSON request failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Generic GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(baseUrl + endpoint));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        try {
          return jsonDecode(response.body); // List or Map
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON: $e'};
        }
      } else {
        return {
          'success': false,
          'message': 'GET request failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// ✅ Specific: Get all projects
  static Future<List<dynamic>> getAllProjects() async {
    final data = await get("get_all_projects.php");
    if (data is List) return data;
    return [];
  }

  /// ✅ Specific: Get tasks by project
  static Future<List<dynamic>> getTasksByProject(int projectId) async {
    final data = await get("get_tasks_by_project.php?project_id=$projectId");
    if (data is List) return data;
    return [];
  }
}