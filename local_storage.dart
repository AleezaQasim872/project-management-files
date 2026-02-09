
import 'package:hive/hive.dart';
import '../models/request_model.dart';

class LocalStorageService {
  static final Box _requestBox = Hive.box('requests');

  // Save request locally
  static void saveRequest(RequestModel request) {
    _requestBox.add(request.toJson());
  }

  // Get all requests
  static List<Map<String, dynamic>> getRequests() {
    return _requestBox.values.cast<Map<String, dynamic>>().toList();
  }

  // Clear data (Admin / Logout)
  static void clearAll() {
    _requestBox.clear();
  }
}