import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/main.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});
  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2400), () {
        if (mounted) checkLoginStatus(context);
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userType = prefs.getString('userType');
    String? uid = prefs.getString('uid');

    if (isLoggedIn && uid != null && userType != null) {
      switch (userType) {
        case 'Hairdresser':
          GoRouter.of(context).pushReplacement(AppRouter.kHairdresserView);
          break;
        case 'BeautyCenter':
          GoRouter.of(context).pushReplacement(AppRouter.kBeautyCenterView);
          break;
        case 'ClientFemale':
          GoRouter.of(context).pushReplacement(AppRouter.kFemaleCustomerView);
          break;
        case 'Barbers':
          GoRouter.of(context).pushReplacement(AppRouter.kBarberView);
          break;
        case 'Customers':
          GoRouter.of(context).pushReplacement(AppRouter.kCustomerView);
          break;
        case 'Clients':
          GoRouter.of(context).pushReplacement(AppRouter.kMaleCustomerView);
          break;
        default:
          GoRouter.of(
            context,
          ).pushReplacement(AppRouter.kServicesSelectionView);
      }
    } else {
      GoRouter.of(context).pushReplacement(AppRouter.kServicesSelectionView);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF274BEF),
                  Color(0xFF0D1B2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/logoo_app.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: const Text(
                        'CURLY',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      'Your beauty, your style',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: .55),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  FadeTransition(
                    opacity: _taglineFade,
                    child: SizedBox(
                      width: 40,
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: .1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD0D5E8),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .04)
      ..style = PaintingStyle.fill;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
