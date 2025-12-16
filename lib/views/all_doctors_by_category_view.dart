  import 'package:firebase_database/firebase_database.dart';
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:sehha_app/core/tools/app_localizations%20.dart';
  import 'package:sehha_app/core/utils/app_colors.dart';
  import 'package:sehha_app/models/doctor_model.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

  class AllDoctorsByCategoryView extends StatelessWidget {
    final String category;

    const AllDoctorsByCategoryView({super.key, required this.category});

    @override
    Widget build(BuildContext context) {
      final DatabaseReference doctorDB = FirebaseDatabase.instance.ref('Doctors');

      return Scaffold(
        appBar: AppBar(
          title: Text(category, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: AppColors.scondaryColor,
        ),
        body: StreamBuilder(
          stream: doctorDB.orderByChild('category').equalTo(category).onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CustomCircularProgressIndicator());
            }

            if (snapshot.data!.snapshot.value == null) {
              return Center(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('no_doctors_in_category'),
                ),
              );
            }

            final doctorsMap = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final doctorsList = doctorsMap.entries.map((e) {
              final data = Map<String, dynamic>.from(e.value);
              return DoctorModel.fromMap(data);
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doctorsList.length,
              itemBuilder: (context, index) {
                final doctor = doctorsList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                doctor.profileImage.isNotEmpty
                                    ? doctor.profileImage
                                    : 'https://via.placeholder.com/150',
                              ),
                            ),
                           const  Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${doctor.firstName} ${doctor.lastName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.category,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${doctor.yearsOfExperience} ${AppLocalizations.of(context).translate('years_experience')}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Row(
                                children: [
                                 const  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor.totalReviews} (${doctor.numberOfReviews} reviews)',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            GoRouter.of(context).push(
                              '/chatView',
                              extra: {
                                'doctorId': doctor.uid,
                                'doctorName':
                                    '${doctor.firstName} ${doctor.lastName}',
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
