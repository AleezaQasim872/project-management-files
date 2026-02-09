// lib/services/notification_service_web.dart

import 'dart:html' as html;

class NotificationService {
  Future<void> init() async {}

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    } else if (html.Notification.permission != 'denied') {
      await html.Notification.requestPermission();
    }
  }

  /// Web me scheduling supported nahi
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required dynamic scheduledTime,
  }) async {}

  Future<void> cancel(int id) async {}

  Future<void> cancelAll() async {}
}