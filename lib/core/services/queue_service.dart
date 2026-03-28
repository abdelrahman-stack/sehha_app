import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/core/models/booking_appointment_model.dart';
import 'fcm_sender.dart';

class QueueService {
  static Future<void> updateCurrentTurn({
    required String barberId,
    required int currentTurn,
  }) async {
    await FirebaseDatabase.instance
        .ref('Barbers/$barberId/currentTurn')
        .set(currentTurn);

    final requestsSnap = await FirebaseDatabase.instance
        .ref('Requests')
        .orderByChild('reciver')
        .equalTo(barberId)
        .get();

    if (!requestsSnap.exists) return;

    final data = Map<String, dynamic>.from(requestsSnap.value as Map);

    for (final item in data.values) {
      final booking = BookingAppointmentModel.fromMap(
        Map<String, dynamic>.from(item),
      );

      final tokenSnap = await FirebaseDatabase.instance
          .ref('Clients/${booking.sender}/fcmToken')
          .get();

      if (!tokenSnap.exists) continue;

      final clientToken = tokenSnap.value.toString();

      // دورك قرب
      if (booking.turnNumber - currentTurn == 1) {
        await FcmSender.send(
          token: clientToken,
          title: 'استعد',
          body: 'دورك قرب ✂️',
        );
      }

      // دورك الآن
      if (booking.turnNumber == currentTurn) {
        await FcmSender.send(
          token: clientToken,
          title: 'دورك الآن',
          body: 'اتفضل جهز نفسك',
        );
      }
    }
  }
}
