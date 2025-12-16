import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/models/patient_model.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class DoctorChatListView extends StatefulWidget {
  const DoctorChatListView({super.key});

  @override
  State<DoctorChatListView> createState() => _DoctorChatListViewState();
}

class _DoctorChatListViewState extends State<DoctorChatListView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference chatListDB = FirebaseDatabase.instance.ref('chatList');
  final DatabaseReference patientDB = FirebaseDatabase.instance.ref('Patients');

  List<PatientModel> patients = [];
  bool isLoading = true;
  late String doctorId;

  @override
  void initState() {
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      doctorId = currentUser.uid;
      fetchChatList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchChatList() async {
    try {
      final DatabaseEvent event = await chatListDB.child(doctorId).once();
      final snapshot = event.snapshot;

      List<PatientModel> tempPatients = [];

      if (snapshot.value != null) {
        final Map<dynamic, dynamic> patientsMap = snapshot.value as Map<dynamic, dynamic>;

        for (var patientId in patientsMap.keys) {
          final DatabaseEvent patientEvent = await patientDB.child(patientId).once();
          final patientSnapshot = patientEvent.snapshot;

          if (patientSnapshot.value != null) {
            final Map<dynamic, dynamic> patientMap = patientSnapshot.value as Map<dynamic, dynamic>;
            tempPatients.add(PatientModel.fromMap(Map<String, dynamic>.from(patientMap)));
          }
        }
      }

      setState(() {
        patients = tempPatients;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          t.translate('patients_chat_list'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.scondaryColor,
      ),
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : patients.isEmpty
              ? Center(child: Text(t.translate('no_patients_found')))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(patient.profileImage),
                        ),
                        title: Text('${patient.firstName} ${patient.lastName}'),
                        subtitle: Text(patient.email),
                        trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.scondaryColor),
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRouter.kChatView,
                            extra: {
                              'doctorId': doctorId,
                              'doctorName': auth.currentUser?.displayName ?? t.translate('doctor'),
                              'patientId': patient.uid,
                              'patientName': '${patient.firstName} ${patient.lastName}',
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
