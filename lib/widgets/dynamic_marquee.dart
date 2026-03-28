import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class DynamicMarquee extends StatelessWidget {
  const DynamicMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> messages = [
      'مرحبًا بك في Curly – اكتشف أقرب صالون وحجز خدماتك بسهولة وسرعة!',
      'احجز الآن أقرب صالون أو كوافير حريمي بجوارك!',
      'منتجات تجميل أصلية متوفرة داخل التطبيق!',
      'خدمات الصيانة متوفرة لكل صالونات Curly!',
    ];

    final marqueeText = messages.join('     ✦     ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade400, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      height: 30,

      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Marquee(
          text: marqueeText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          blankSpace: 50.0,
          velocity: 50.0,
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      ),
    );
  }
}
