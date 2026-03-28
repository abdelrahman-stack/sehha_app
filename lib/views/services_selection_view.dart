import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/admin/cubit/cubit/admin_cubit.dart';
import 'package:sehha_app/admin/views/admin_login_view.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/widgets/dynamic_marquee.dart';

class ServicesSelectionView extends StatefulWidget {
  const ServicesSelectionView({super.key});

  @override
  State<ServicesSelectionView> createState() => _ServicesSelectionViewState();
}

class _ServicesSelectionViewState extends State<ServicesSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _services = [
    const _ServiceItem(
      label: 'العناية الشخصية – رجال',
      icon: Icons.content_cut_rounded,
      color: Color(0xFF1565C0),
      accentColor: Color(0xFF42A5F5),
      route: AppRouter.kMaleAuthView,
    ),
    const _ServiceItem(
      label: 'العناية الشخصية – سيدات',
      icon: Icons.face_retouching_natural_rounded,
      color: Color(0xFFC2185B),
      accentColor: Color(0xFFF48FB1),
      route: AppRouter.kFemaleAuthView,
    ),
    const _ServiceItem(
      label: 'مراكز التجميل',
      icon: Icons.spa_rounded,
      color: Color(0xFF6A1B9A),
      accentColor: Color(0xFFCE93D8),
      route: AppRouter.kBeautyCenterAuthView,
    ),
    const _ServiceItem(
      label: 'خدمة العملاء والدفع',
      icon: Icons.headset_mic_rounded,
      color: Color(0xFF00695C),
      accentColor: Color(0xFF80CBC4),
      route: AppRouter.kSupportAndPaymentView,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _slideAnimations = List.generate(_services.length, (i) {
      final start = i * 0.15;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

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
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        final shouldExit = await _showExitDialog(context);
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
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
              top: -80,
              right: -80,
              child: _GlowCircle(size: 260, color: Color(0xFF1565C0)),
            ),
            const Positioned(
              bottom: -100,
              left: -60,
              child: _GlowCircle(size: 220, color: Color(0xFF0D47A1)),
            ),
            const Positioned(
              top: 180,
              left: -50,
              child: _GlowCircle(size: 130, color: Color(0xFF42A5F5)),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth < 600 ? double.infinity : 500,
                  ),
                  child: Column(
                    children: [
                      const DynamicMarquee(),

                      const Spacer(flex: 1),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (_) => AdminAuthCubit(),
                                        child: const AdminLoginView(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: .08),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: .2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF42A5F5,
                                        ).withValues(alpha: .3),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.cut_outlined,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'خدماتك على كيفك',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: .5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black38,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'اختر الخدمة المناسبة لك',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .55),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(_services.length, (i) {
                            final svc = _services[i];
                            return SlideTransition(
                              position: _slideAnimations[i],
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _ServiceCard(item: svc),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const Spacer(flex: 1),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'نسهّللك اختيار خدماتك بسرعة وأمان',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3A5C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: .1), width: 1),
        ),
        title: const Text(
          'الخروج من التطبيق',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Text(
          'هل تريد الخروج من التطبيق؟',
          style: TextStyle(color: Colors.white.withValues(alpha: .7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.white.withValues(alpha: .5)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ServiceCard extends StatefulWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _pressController.reverse();
        GoRouter.of(context).push(item.route);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _pressController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                item.color.withValues(alpha: _pressed ? .95 : .85),
                item.accentColor.withValues(alpha: _pressed ? .7 : .55),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            border: Border.all(
              color: item.accentColor.withValues(alpha: .35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: _pressed ? .5 : .3),
                blurRadius: _pressed ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: .6),
                  size: 16,
                ),
              ],
            ),
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

class _ServiceItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final String route;

  const _ServiceItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.route,
  });
}
