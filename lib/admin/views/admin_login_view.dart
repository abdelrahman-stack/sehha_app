import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/constants.dart';
import 'package:sehha_app/core/utils/app_router.dart';

const _kDark = Color(0xFF0A0E1A);
const _kDark2 = Color(0xFF121C30);
const _kBlue = Color(0xFF274BEF);

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});
  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

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
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (email.text != adminEmail) {
      _snack('غير مصرح بالدخول', Colors.redAccent);
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kAdminDashboardView);
      }
    } catch (_) {
      _snack('بريد أو كلمة مرور غلط', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color bg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Positioned(top: -70, right: -60, child: _Glow(240, _kBlue)),
          const Positioned(bottom: -90, left: -60, child: _Glow(210, _kBlue)),
          Positioned.fill(child: CustomPaint(painter: _DotPainter())),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: _kBlue.withValues(alpha: .15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _kBlue.withValues(alpha: .5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _kBlue.withValues(alpha: .35),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'لوحة التحكم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تسجيل دخول المشرف',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .45),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 36),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .09),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _DarkField(
                                ctrl: email,
                                label: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),
                              _DarkField(
                                ctrl: password,
                                label: 'كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                suffix: GestureDetector(
                                  onTap: () =>
                                      setState(() => _obscure = !_obscure),
                                  child: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white38,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              GestureDetector(
                                onTap: _loading ? null : login,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 54,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _loading
                                          ? [Colors.white12, Colors.white10]
                                          : [
                                              _kBlue,
                                              _kBlue.withValues(alpha: .75),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _loading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: _kBlue.withValues(
                                                alpha: .55,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'دخول',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;
  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: keyboard,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    cursorColor: _kBlue,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white30, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _kBlue.withValues(alpha: .7), width: 1.5),
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow(this.size, this.color);
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

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 28) {
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
