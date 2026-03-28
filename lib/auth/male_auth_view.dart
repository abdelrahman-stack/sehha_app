import 'package:flutter/material.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/utils/app_router.dart';

class MaleAuthView extends StatefulWidget {
  const MaleAuthView({super.key});

  @override
  State<MaleAuthView> createState() => _MaleAuthViewState();
}

class _MaleAuthViewState extends State<MaleAuthView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _btnSlide1;
  late Animation<Offset> _btnSlide2;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _btnSlide1 = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _btnSlide2 = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية dark متناسقة مع الشاشة الرئيسية ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          const Positioned(
            top: -60,
            right: -60,
            child: _GlowCircle(size: 220, color: AppColors.secondaryColor),
          ),
          const Positioned(
            bottom: -80,
            left: -50,
            child: _GlowCircle(size: 200, color: Color(0xFF0D47A1)),
          ),
          const Positioned(
            top: 220,
            left: -30,
            child: _GlowCircle(size: 100, color: AppColors.accentColor),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
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
                                      color:
                                          Colors.white.withValues(alpha: .18),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondaryColor
                                            .withValues(alpha: .35),
                                        blurRadius: 28,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.content_cut_rounded,
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  'العناية الشخصية',
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
                                      horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryColor
                                        .withValues(alpha: .25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.secondaryColor
                                          .withValues(alpha: .5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'رجال ✂️',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'اختر تسجيل الدخول أو إنشاء حساب جديد\nللوصول إلى خدمات العناية المخصصة للرجال.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors.white.withValues(alpha: .55),
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
                                position: _btnSlide1,
                                child: _AuthButton(
                                  label: 'تسجيل الدخول',
                                  icon: Icons.login_rounded,
                                  isPrimary: true,
                                  onTap: () => GoRouter.of(context)
                                      .push(AppRouter.kMaleSignInView),
                                ),
                              ),

                              const SizedBox(height: 14),

                              SlideTransition(
                                position: _btnSlide2,
                                child: _AuthButton(
                                  label: 'إنشاء حساب جديد',
                                  icon: Icons.person_add_alt_1_rounded,
                                  isPrimary: false,
                                  onTap: () => GoRouter.of(context)
                                      .push(AppRouter.kMaleSignUpView),
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

class _AuthButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      AppColors.secondaryColor,
                      AppColors.secondaryColor
                          .withBlue(255)
                          .withRed(20),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  )
                : null,
            color: widget.isPrimary
                ? null
                : Colors.white.withValues(alpha: .07),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: .2),
              width: 1.5,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color:
                          AppColors.secondaryColor.withValues(alpha: .45),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 20,
              ),
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
}


class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .12),
      ),
    );
  }
}