// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _local =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     const androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const initSettings =
//         InitializationSettings(android: androidInit);

//     await _local.initialize(initSettings);

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   final type = message.data['type'] ?? '';

//   String title = message.notification?.title ?? '';
//   String body = message.notification?.body ?? '';

//   _showLocalNotification(title: title, body: body);
// });

//   }

//   static Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'main_channel',
//       'App Notifications',
//       channelDescription: 'App notifications channel',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );

//     const details = NotificationDetails(android: androidDetails);

//     await _local.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 10,
//       title,
//       body,
//       details,
//     );
//   }

//   static Future<String?> getToken() async {
//     return await _fcm.getToken();
//   }
// }
