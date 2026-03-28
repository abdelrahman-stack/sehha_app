import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/utils/app_router.dart';

class BeautyCenterAuthView extends StatefulWidget {
  const BeautyCenterAuthView({super.key});
  @override
  State<BeautyCenterAuthView> createState() => _BeautyCenterAuthViewState();
}

class _BeautyCenterAuthViewState extends State<BeautyCenterAuthView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl, _slideCtrl;
  late Animation<double> _fadeAnim, _scaleAnim;
  late Animation<Offset> _btn1, _btn2;

  static const _primary = Color(0xFF4A148C);
  static const _accent = Color(0xFF9C27B0);
  static const _gold = Color(0xFFFFD54F);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutBack));
    _btn1 = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _btn2 = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideCtrl,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF120A1E), Color(0xFF2D1B45)],
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
            child: _GlowCircle(size: 200, color: _accent),
          ),
          const Positioned(
            top: 200,
            left: -30,
            child: _GlowCircle(size: 110, color: _gold),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        FadeTransition(
                          opacity: _fadeAnim,
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: .07),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: .18,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: .4),
                                        blurRadius: 28,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.spa_rounded,
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'مراكز التجميل',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: .5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _gold.withValues(alpha: .5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'Beauty Center ✨',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'اختر تسجيل الدخول أو إنشاء حساب جديد\nللوصول إلى خدمات مراكز التجميل.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: .55),
                                    height: 1.7,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              SlideTransition(
                                position: _btn1,
                                child: _AuthBtn(
                                  label: 'تسجيل الدخول',
                                  icon: Icons.login_rounded,
                                  isPrimary: true,
                                  primary: _primary,
                                  accent: _accent,
                                  onTap: () => GoRouter.of(
                                    context,
                                  ).push(AppRouter.kBeautyCenterSignIn),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SlideTransition(
                                position: _btn2,
                                child: _AuthBtn(
                                  label: 'إنشاء حساب جديد',
                                  icon: Icons.person_add_alt_1_rounded,
                                  isPrimary: false,
                                  primary: _primary,
                                  accent: _accent,
                                  onTap: () => GoRouter.of(
                                    context,
                                  ).push(AppRouter.kBeautyCenterSignUp),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'بياناتك آمنة ومحمية بالكامل 🔒',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .3),
                                fontSize: 12,
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
          ),
        ],
      ),
    );
  }
}

class _AuthBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color primary, accent;
  final VoidCallback onTap;
  const _AuthBtn({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.primary,
    required this.accent,
    required this.onTap,
  });
  @override
  State<_AuthBtn> createState() => _AuthBtnState();
}

class _AuthBtnState extends State<_AuthBtn>
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
      end: 0.96,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) {
      _c.reverse();
      widget.onTap();
    },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(
      scale: _s,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: widget.isPrimary
              ? LinearGradient(
                  colors: [widget.primary, widget.accent],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              : null,
          color: widget.isPrimary ? null : Colors.white.withValues(alpha: .07),
          border: Border.all(
            color: widget.isPrimary
                ? Colors.transparent
                : Colors.white.withValues(alpha: .2),
            width: 1.5,
          ),
          boxShadow: widget.isPrimary
              ? [
                  BoxShadow(
                    color: widget.primary.withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
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
