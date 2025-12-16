import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/core/utils/assets.dart';

class AllSpecialtiesView extends StatelessWidget {
  const AllSpecialtiesView({super.key});

  final List<Map<String, dynamic>> specialties = const [
    {'name': 'طبيب أسنان', 'image': Assets.assetsImagesIcons8Dentistry24},
    {'name': 'أمراض قلب', 'image': Assets.assetsImagesIcons8Cardiology48},
    {'name': 'أطفال', 'image': Assets.assetsImagesIcons8InfantMassage48},
    {'name': 'مخ وأعصاب', 'image': Assets.assetsImagesIcons8NeurologyScience64},
    {'name': 'جلدية', 'image': Assets.assetsImagesIcons8Dermatology48},
    {'name': 'عظام', 'image': Assets.assetsImagesIcons8Orthopedic64},
    {'name': 'نساء وتوليد', 'image': Assets.assetsImagesIcons8Fetus48},
    {
      'name': 'أمراض الجهاز الهضمي',
      'image': Assets.assetsImagesIcons8InternalMedicine24,
    },
    {'name': 'عيون', 'image': Assets.assetsImagesIcons8Ophthalmology48},
  ];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.translate('all_specialties'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.scondaryColor,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];

          String specialtyName = locale.translate(
            specialty['name'].toString().toLowerCase(),
          );

          return GestureDetector(
            onTap: () {
              GoRouter.of(context).push(
                AppRouter.kAllDoctorsByCategoryView,
                extra: specialty['name'],
              );
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.scondaryColor,
                      AppColors.scondaryColor.withValues(alpha: .6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      specialty['image'],
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        specialtyName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
