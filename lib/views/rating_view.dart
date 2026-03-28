import 'package:flutter/material.dart';
import 'package:sehha_app/core/services/rating_service.dart';
import 'package:sehha_app/core/utils/app_colors.dart';

class RatingView extends StatefulWidget {
  final String barberId;
  final String bookingId;

  const RatingView({
    super.key,
    required this.barberId,
    required this.bookingId,
  });

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView>
    with SingleTickerProviderStateMixin {
  double rating = 0;
  final commentController = TextEditingController();
  bool loading = false;

  late AnimationController _animController;
  late List<Animation<double>> _starAnimations;

  final List<String> _ratingLabels = [
    '',
    'سيئ جداً 😞',
    'سيئ 😕',
    'مقبول 😐',
    'جيد 😊',
    'ممتاز! 🔥',
  ];

  final List<Color> _ratingColors = [
    Colors.transparent,
    const Color(0xFFEF233C),
    const Color(0xFFFF6B35),
    const Color(0xFFFFC300),
    const Color(0xFF90BE6D),
    const Color(0xFF06D6A0),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _starAnimations = List.generate(5, (i) {
      final start = i * 0.12;
      final end = start + 0.4;
      return Tween<double>(begin: 1.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
              curve: Curves.elasticOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    setState(() => rating = index + 1.0);
    _animController.forward(from: 0);
  }

  Color get _activeColor =>
      rating > 0 ? _ratingColors[rating.toInt()] : const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // ── خلفية علوية بلون متدرج ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    rating > 0
                        ? _activeColor.withValues(alpha: .8)
                        : AppColors.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          const Positioned(
            top: -40,
            right: -40,
            child: _DecorCircle(size: 180, opacity: .08),
          ),
          const Positioned(
            top: 60,
            left: -30,
            child: _DecorCircle(size: 120, opacity: .06),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── شريط علوي ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'تقييم الخدمة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // ── أيقونة المقص ──
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: .4), width: 2),
                  ),
                  child: const Icon(Icons.content_cut_rounded,
                      color: Colors.white, size: 36),
                ),

                const SizedBox(height: 12),
                const Text(
                  'كيف كانت تجربتك؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رأيك يساعدنا نحسن الخدمة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                // ── الكارت الرئيسي ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        children: [
                          // ── النجوم ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final filled = i < rating;
                              return AnimatedBuilder(
                                animation: _starAnimations[i],
                                builder: (context, _) {
                                  return Transform.scale(
                                    scale: filled
                                        ? _starAnimations[i].value
                                        : 1.0,
                                    child: GestureDetector(
                                      onTap: () => _onStarTap(i),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Icon(
                                          filled
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 48,
                                          color: filled
                                              ? _activeColor
                                              : const Color(0xFFDDE1E7),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),

                          const SizedBox(height: 12),

                          // ── نص وصف التقييم ──
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: rating > 0
                                ? Container(
                                    key: ValueKey(rating.toInt()),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _activeColor
                                          .withValues(alpha: .12),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _ratingLabels[rating.toInt()],
                                      style: TextStyle(
                                        color: _activeColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey(0), height: 40),
                          ),

                          const SizedBox(height: 28),

                          // ── حقل التعليق ──
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'تعليقك (اختياري)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: commentController,
                            maxLines: 4,
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(
                              hintText: 'شاركنا تجربتك بالتفصيل...',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color:  AppColors.primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── أزرار ──
                          if (loading)
                            const CircularProgressIndicator(
                                color: AppColors.primaryColor)
                          else ...[
                            // زرار إرسال
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: AnimatedOpacity(
                                opacity: rating > 0 ? 1.0 : 0.45,
                                duration: const Duration(milliseconds: 300),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryColor,
                                        AppColors.secondaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: rating > 0
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: .4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: rating > 0
                                        ? () async {
                                            setState(() => loading = true);
                                            await RatingService.submitRating(
                                              barberId: widget.barberId,
                                              bookingId: widget.bookingId,
                                              rating: rating,
                                              comment: commentController.text,
                                            );
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'إرسال التقييم',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // زرار لاحقاً
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton(
                                onPressed: () async {
                                  await RatingService.skipRating(
                                      widget.bookingId);
                                  if (mounted) Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  'تقييم لاحقاً',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                        ],
                      ),
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

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}