import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/models/doctor_model.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class AllDoctorsView extends StatelessWidget {
  const AllDoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference doctorDB = FirebaseDatabase.instance.ref('Doctors');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('all_doctors'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.scondaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: doctorDB.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CustomCircularProgressIndicator());
          }

          final doctorsMap = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final doctorsList = doctorsMap.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value);
            return DoctorModel.fromMap(data);
          }).toList();

          if (doctorsList.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).translate('no_doctors_found'),
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: doctorsList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final doctor = doctorsList[index];
                final isOnline = doctor.numberOfReviews > 0;
                return GestureDetector(
                  onTap: () {
                    GoRouter.of(
                      context,
                    ).push('/DoctorDetailsView', extra: doctor);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Image.network(
                                doctor.profileImage,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Text(
                                '${doctor.firstName} ${doctor.lastName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.category,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppLocalizations.of(context).translate('experience')}: ${doctor.yearsOfExperience} ${AppLocalizations.of(context).translate('yrs')}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
