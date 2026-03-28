import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehha_app/main.dart';

class NotificationDemo extends StatelessWidget {
  const NotificationDemo({super.key});

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel', 
      'Test Channel', 
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'مرحبا 👋',
      'ده إشعار تجريبي شغال',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: showNotification,
          child: const Text('اعرض إشعار الآن'),
        ),
      ),
    );
  }
}