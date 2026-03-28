import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sehha_app/core/services/fcm_service.dart';
import 'package:sehha_app/core/services/shared_prefs.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_router.dart';

// ── ألوان ──
const _kPink = Color(0xFFAD1457);
const _kPink2 = Color(0xFF880E4F);
const _kAccent = Color(0xFFE91E8C);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);
const _kSurface = Color(0xFF1C1020);

class BeautyCenterSignin extends StatefulWidget {
  const BeautyCenterSignin({super.key});
  @override
  State<BeautyCenterSignin> createState() => _BeautyCenterSigninState();
}

class _BeautyCenterSigninState extends State<BeautyCenterSignin>
    with SingleTickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isNavigator = false;
  bool _obscure = true;

  String email = '';
  String password = '';

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: _kDark,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kDark, _kDark2, _kDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, .5, 1],
                  ),
                ),
              ),
              const Positioned(
                top: -80,
                right: -60,
                child: _Glow(250, _kPink, .08),
              ),
              const Positioned(
                bottom: -60,
                left: -60,
                child: _Glow(200, _kAccent, .06),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * .35,
                left: -40,
                child: const _Glow(140, _kPink2, .06),
              ),
              Positioned.fill(child: CustomPaint(painter: _DotGrid(_kAccent))),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveBreakpoints.of(context).isMobile
                            ? double.infinity
                            : 480,
                      ),
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _kAccent.withValues(alpha: .06),
                                        border: Border.all(
                                          color: _kAccent.withValues(
                                            alpha: .15,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _kPink.withValues(alpha: .08),
                                        border: Border.all(
                                          color: _kPink.withValues(alpha: .25),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _kPink.withValues(alpha: .4),
                                            blurRadius: 28,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/beauty_center_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'مرحباً بك 💫',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  local.translate(
                                    'sign_in_to_continue_your_journey',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .4),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: _kSurface.withValues(alpha: .8),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: .07,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: .3,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      _Field(
                                        label: local.translate('email'),
                                        icon: Icons.email_outlined,
                                        keyboard: TextInputType.emailAddress,
                                        onChanged: (v) => email = v,
                                        validator: (v) => v!.isEmpty
                                            ? local.translate(
                                                'enter_your_email',
                                              )
                                            : null,
                                        accent: _kAccent,
                                      ),
                                      const SizedBox(height: 14),
                                      _Field(
                                        label: local.translate('password'),
                                        icon: Icons.lock_outline_rounded,
                                        onChanged: (v) => password = v,
                                        validator: (v) => (v?.length ?? 0) < 6
                                            ? local.translate(
                                                'password_must_be_at_least_6_characters',
                                              )
                                            : null,
                                        accent: _kAccent,
                                        obscure: _obscure,
                                        suffix: GestureDetector(
                                          onTap: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                          child: Icon(
                                            _obscure
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white30,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 22),

                                      GestureDetector(
                                        onTap: isLoading ? null : signin,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          height: 54,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isLoading
                                                  ? [
                                                      Colors.white10,
                                                      Colors.white10,
                                                    ]
                                                  : [_kAccent, _kPink2],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: isLoading
                                                ? []
                                                : [
                                                    BoxShadow(
                                                      color: _kAccent
                                                          .withValues(
                                                            alpha: .5,
                                                          ),
                                                      blurRadius: 20,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                  )
                                                : Text(
                                                    local.translate('sign_in'),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      local.translate('don_t_have_an_account'),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: .4,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => GoRouter.of(
                                        context,
                                      ).push(AppRouter.kBeautyCenterSignUp),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          local.translate('sign_up'),
                                          style: const TextStyle(
                                            color: _kAccent,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (token != null) {
      await FirebaseDatabase.instance.ref('users/$uid/fcmToken').set(token);
    }
  }

  Future<void> signin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        final bcSnap = await ref.child('BeautyCenter').child(user.uid).get();
        if (bcSnap.exists) {
          await FcmService.saveToken(userType: 'BeautyCenter');
          await saveUserLoginState(user.uid, 'BeautyCenter');
          _go(AppRouter.kBeautyCenterView);
        } else {
          final custSnap = await ref.child('Customers').child(user.uid).get();
          if (custSnap.exists) {
            await FcmService.saveToken(userType: 'Customers');
            await saveUserLoginState(user.uid, 'Customers');
            _go(AppRouter.kCustomerView);
          } else {
            _snack('User not found!');
          }
        }
      }
    } catch (e) {
      _snack('فشل تسجيل الدخول: $e');
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _go(String route) {
    if (!isNavigator) {
      isNavigator = true;
      GoRouter.of(context).pushReplacement(route);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Color accent;
  final bool obscure;
  final Widget? suffix;
  const _Field({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboard = TextInputType.text,
    this.validator,
    required this.accent,
    this.obscure = false,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    keyboardType: keyboard,
    onChanged: onChanged,
    validator: validator,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    cursorColor: accent,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .35),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white24, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: accent.withValues(alpha: .65),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Glow(this.size, this.color, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

class _DotGrid extends CustomPainter {
  final Color c;
  _DotGrid(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = c.withValues(alpha: .018)
      ..style = PaintingStyle.fill;
    for (double x = 20; x < s.width; x += 28)
      for (double y = 20; y < s.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
  }

  @override
  bool shouldRepaint(_) => false;
}
