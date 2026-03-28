import 'package:flutter/material.dart';
import 'package:sehha_app/core/utils/app_colors.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  final String? message;
  const CustomCircularProgressIndicator({super.key, this.message});
  @override
  State<CustomCircularProgressIndicator> createState() => _State();
}

class _State extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = Tween<double>(
      begin: .3,
      end: .7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryColor.withValues(
                            alpha: _fade.value,
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryColor.withValues(alpha: .08),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor.withValues(
                            alpha: _fade.value * .6,
                          ),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: 0.5 + (_fade.value * 0.5),
              child: Text(
                widget.message ?? "جارٍ التحميل...",
                style: TextStyle(
                  color: AppColors.secondaryColor.withValues(alpha: .8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
