import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sehha_app/core/services/fcm_service.dart';
import 'package:sehha_app/core/services/shared_prefs.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_router.dart';

class FemaleSignInView extends StatefulWidget {
  const FemaleSignInView({super.key});
  @override
  State<FemaleSignInView> createState() => _FemaleSignInViewState();
}

class _FemaleSignInViewState extends State<FemaleSignInView>
    with TickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false, isNavigator = false;
  bool isPasswordVisible = false;
  String email = '', password = '';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _headerSlide, _formSlide;

  static const _primary = Color(0xFF880E4F);
  static const _accent = Color(0xFFE91E8C);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _fadeCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _fadeCtrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0A10), Color(0xFF3D1A2A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const Positioned(
              top: -60,
              right: -60,
              child: _GlowCircle(size: 220, color: _primary),
            ),
            const Positioned(
              bottom: -80,
              left: -50,
              child: _GlowCircle(size: 200, color: Color(0xFF880E4F)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveBreakpoints.of(context).isMobile
                          ? double.infinity
                          : 480,
                    ),
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(height: 16),

                            SlideTransition(
                              position: _headerSlide,
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(
                                          alpha: .07,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: .18,
                                          ),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accent.withValues(
                                              alpha: .4,
                                            ),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.spa_rounded,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      local.translate('welcome'),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      local.translate(
                                        'sign_in_to_continue_your_journey',
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            SlideTransition(
                              position: _formSlide,
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  children: [
                                    _DarkTextField(
                                      label: local.translate('email'),
                                      icon: Icons.email_outlined,
                                      accentColor: _accent,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (v) => email = v,
                                      validator: (v) => v!.isEmpty
                                          ? local.translate('enter_your_email')
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    _DarkTextField(
                                      label: local.translate('password'),
                                      icon: Icons.lock_outline_rounded,
                                      accentColor: _accent,
                                      obscureText: !isPasswordVisible,
                                      onChanged: (v) => password = v,
                                      validator: (v) => v!.length < 6
                                          ? local.translate(
                                              'password_must_be_at_least_6_characters',
                                            )
                                          : null,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => isPasswordVisible =
                                              !isPasswordVisible,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    _GradientButton(
                                      label: local.translate('sign_in'),
                                      isLoading: isLoading,
                                      primary: _primary,
                                      accent: _accent,
                                      onTap: isLoading ? null : signin,
                                    ),

                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          local.translate(
                                            'don_t_have_an_account',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: .5,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => GoRouter.of(
                                            context,
                                          ).push(AppRouter.kFemaleSignUpView),
                                          child: Text(
                                            local.translate('sign_up'),
                                            style: const TextStyle(
                                              color: _accent,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
        await saveFCMToken();
        final hairdresserSnap = await ref
            .child('Hairdressers')
            .child(user.uid)
            .get();
        if (hairdresserSnap.exists) {
          await FcmService.saveToken(userType: 'Hairdressers');
          await saveUserLoginState(user.uid, 'Hairdressers');
          navigateToHairdresserView();
          return;
        }
        final clientSnap = await ref
            .child('ClientFemales')
            .child(user.uid)
            .get();
        if (clientSnap.exists) {
          await FcmService.saveToken(userType: 'ClientFemales');
          await saveUserLoginState(user.uid, 'ClientFemales');
          navigateToClientFemaleView();
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    }
    setState(() => isLoading = false);
  }

  void navigateToHairdresserView() {
    if (!isNavigator) {
      isNavigator = true;
      GoRouter.of(context).pushReplacement(AppRouter.kHairdresserView);
    }
  }

  void navigateToClientFemaleView() {
    if (!isNavigator) {
      isNavigator = true;
      GoRouter.of(context).pushReplacement(AppRouter.kFemaleCustomerView);
    }
  }
}

class _DarkTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? initialValue;
  const _DarkTextField({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.initialValue,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue,
    obscureText: obscureText,
    keyboardType: keyboardType,
    onChanged: onChanged,
    validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .5),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: accentColor.withValues(alpha: .7),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    ),
  );
}

class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color primary, accent;
  final VoidCallback? onTap;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.primary,
    required this.accent,
    this.onTap,
  });
  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: widget.onTap != null ? (_) => _c.forward() : null,
    onTapUp: widget.onTap != null
        ? (_) {
            _c.reverse();
            widget.onTap!();
          }
        : null,
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(
      scale: _s,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: widget.onTap != null
              ? LinearGradient(
                  colors: [widget.primary, widget.accent],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              : null,
          color: widget.onTap == null ? Colors.white12 : null,
          boxShadow: widget.onTap != null
              ? [
                  BoxShadow(
                    color: widget.primary.withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    ),
  );
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: .12),
    ),
  );
}
