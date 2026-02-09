import 'package:flutter/material.dart';

class RequestModel {
  final String itemName;
  final int quantity;
  final String status;

  RequestModel({
    required this.itemName,
    required this.quantity,
    required this.status,
  });

  // ================= JSON =================
  Map<String, dynamic> toJson() {
    return {
      "itemName": itemName,
      "quantity": quantity,
      "status": status,
    };
  }

  // ================= UI Helpers (Professional Touch) =================

  /// Status color for UI badges/cards
  Color get statusColor {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Capitalized status for UI text
  String get statusLabel {
    return status[0].toUpperCase() + status.substring(1);
  }
}