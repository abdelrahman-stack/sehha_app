import 'package:flutter/material.dart';
import 'package:sehha_app/core/utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,

    required this.title,
    required this.image,
    this.isHighlighted = false, this.onTap,
  });

  final String title;
   final VoidCallback? onTap;
  final String image;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap ,
      child: AnimatedContainer(
        
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
                  colors: [AppColors.scondaryColor, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? Colors.blue.withValues(alpha: .4)
                  : Colors.black.withValues(alpha: .12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: isHighlighted
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.white
                    : Colors.blue.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(image, width: 40, height: 40, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Colors.white : AppColors.scondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
