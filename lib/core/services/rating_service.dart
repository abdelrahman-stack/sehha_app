import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/core/services/fcm_sender.dart';

class RatingService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static Future<void> submitRating({
    required String barberId,
    required String bookingId,
    required double rating,
    String? comment,
  }) async {
    final clientId = _auth.currentUser!.uid;

    await _db.child('Reviews/$barberId/$bookingId').set({
      'clientId': clientId,
      'rating': rating,
      'comment': comment ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _db.child('Requests/$bookingId').update({
      'ratingStatus': 'done',
    });

    final barberTokenSnap =
        await _db.child('Barbers/$barberId/fcmToken').get();

    if (barberTokenSnap.exists) {
      await FcmSender.send(
        token: barberTokenSnap.value.toString(),
        title: 'تقييم جديد ⭐',
        body: rating >= 4
            ? 'عميل قيّمك تقييم ممتاز 👏'
            : 'عميل قيّمك، راجع التقييم لتحسين الخدمة',
      );
    }
  }

  static Future<void> skipRating(String bookingId) async {
    await _db.child('Requests/$bookingId').update({
      'ratingStatus': 'skipped',
    });
  }
}
