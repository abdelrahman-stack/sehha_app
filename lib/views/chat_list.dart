import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/models/doctor_model.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference chatListDB = FirebaseDatabase.instance.ref(
    'chatList',
  );
  final DatabaseReference doctorDB = FirebaseDatabase.instance.ref('Doctors');
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('chat_list'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.scondaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: chatListDB.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context).translate('error')}: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context).translate('no_chats_yet'),
              ),
            );
          }

          final chatListMap = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          List<String> doctorIdsWithChat = [];

          chatListMap.forEach((doctorId, patientsMap) {
            final patients = Map<String, dynamic>.from(patientsMap);
            if (patients.containsKey(currentUserId)) {
              doctorIdsWithChat.add(doctorId);
            }
          });

          if (doctorIdsWithChat.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).translate('no_chats_yet'),
              ),
            );
          }

          return ListView.separated(
            itemCount: doctorIdsWithChat.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doctorId = doctorIdsWithChat[index];

              return FutureBuilder(
                future: doctorDB.child(doctorId).once(),
                builder: (context, doctorSnapshot) {
                  if (!doctorSnapshot.hasData ||
                      doctorSnapshot.data!.snapshot.value == null) {
                    return const SizedBox();
                  }

                  final doctorDataMap = Map<String, dynamic>.from(
                    doctorSnapshot.data!.snapshot.value as Map,
                  );
                  final doctor = DoctorModel.fromMap(doctorDataMap);

                  return GestureDetector(
                    onTap: () {
                      final currentUser = auth.currentUser!;
                      final docName = '${doctor.firstName} ${doctor.lastName}';
                      GoRouter.of(context).push(
                        AppRouter.kChatView,
                        extra: {
                          'doctorName': docName,
                          'doctorId': doctor.uid,
                          'patientName':
                              currentUser.displayName ??
                              currentUser.email ??
                              "User",
                          'patientId': currentUser.uid,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  doctor.profileImage,
                                ),
                              ),
                              if (doctor.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doctor.firstName} ${doctor.lastName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppLocalizations.of(context).translate('experience')}: ${doctor.yearsOfExperience} ${AppLocalizations.of(context).translate('years')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
