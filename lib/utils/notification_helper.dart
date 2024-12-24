import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification settings
  static Future<void> initNotifications() async {
    // Android initialization
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    // Combine initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Shows a notification with a title and message
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Android notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'ble_channel', // Channel ID
      'BLE Notifications', // Channel name
      channelDescription: 'Notifications for BLE updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    // iOS notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    // Combine platform-specific details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Show the notification
    await _notificationsPlugin.show(
      0, // Notification ID (can be unique)
      title, // Notification title
      body, // Notification body
      notificationDetails,
    );
  }
}
