import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/core/utils/assets.dart';
import 'package:sehha_app/models/doctor_model.dart';
import 'package:sehha_app/widgets/category_card.dart';
import 'package:sehha_app/widgets/doctor_card.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class DoctorListView extends StatefulWidget {
  const DoctorListView({super.key});

  @override
  State<DoctorListView> createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<DoctorListView> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Doctors');
  List<DoctorModel> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchDoctors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    local.translate('find_doctor_text'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    local.translate('find_by_category'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CategoryCard(
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRouter.kAllDoctorsByCategoryView,
                            extra: 'Dentist',
                          );
                        },
                        title: local.translate('dentist'),
                        image: Assets.assetsImagesIcons8Dentistry24,
                      ),
                      CategoryCard(
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRouter.kAllDoctorsByCategoryView,
                            extra: 'Cardiologist',
                          );
                        },
                        title: local.translate('cardiologist'),
                        image: Assets.assetsImagesIcons8Cardiology48,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CategoryCard(
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRouter.kAllDoctorsByCategoryView,
                            extra: 'Pediatrician',
                          );
                        },
                        isHighlighted: false,
                        title: local.translate('pediatrics'),
                        image: Assets.assetsImagesIcons8InfantMassage48,
                      ),
                      CategoryCard(
                        isHighlighted: true,
                        title: local.translate('see_all'),
                        image: Assets.assetsImagesIcons8ViewAll48,
                        onTap: () {
                          GoRouter.of(context).push(AppRouter.kAllSpecialtiesView);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        local.translate('top_doctors'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          GoRouter.of(context).push(AppRouter.kAllDoctorsView);
                        },
                        child: Text(
                          local.translate('view_all'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.scondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            AppRouter.router.push(
                              AppRouter.kDoctorDetailsView,
                              extra: doctors[index],
                            );
                          },
                          child: DoctorCard(doctor: doctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> fetchDoctors() async {
    await ref.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<DoctorModel> tempDoctors = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            value['uid'] = key;
            tempDoctors.add(DoctorModel.fromMap(value));
          }
        });

        setState(() {
          doctors = tempDoctors;
          isLoading = false;
        });
      }
    });
  }
}
