import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_router.dart';
import '../../core/models/provider_service_model.dart';

class MaleCustomerChatList extends StatefulWidget {
  const MaleCustomerChatList({super.key});
  @override
  State<MaleCustomerChatList> createState() => _MaleCustomerChatListState();
}

class _MaleCustomerChatListState extends State<MaleCustomerChatList> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference chatListDB = FirebaseDatabase.instance.ref(
    'chatList',
  );
  final DatabaseReference barberDB = FirebaseDatabase.instance.ref('Barbers');
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
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
          Positioned(
            top: -40,
            right: -40,
            child: _Glow(180, AppColors.secondaryColor),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _Glow(140, const Color(0xFF0D47A1)),
          ),

          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'محادثاتي',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 38),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder(
                    stream: chatListDB.onValue,
                    builder: (ctx, snap) {
                      if (!snap.hasData || snap.data!.snapshot.value == null) {
                        return _buildEmpty();
                      }
                      final chatMap = Map<String, dynamic>.from(
                        snap.data!.snapshot.value as Map,
                      );
                      final List<String> barberIds = [];
                      chatMap.forEach((barberId, patientsMap) {
                        final patients = Map<String, dynamic>.from(patientsMap);
                        if (patients.containsKey(currentUserId)) {
                          barberIds.add(barberId);
                        }
                      });
                      if (barberIds.isEmpty) return _buildEmpty();

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: barberIds.length,
                        itemBuilder: (ctx, i) {
                          return FutureBuilder(
                            future: barberDB.child(barberIds[i]).once(),
                            builder: (ctx, barberSnap) {
                              if (!barberSnap.hasData ||
                                  barberSnap.data!.snapshot.value == null) {
                                return const SizedBox();
                              }
                              final barber = ProviderServiceModel.fromMap(
                                Map<String, dynamic>.from(
                                  barberSnap.data!.snapshot.value as Map,
                                ),
                              );
                              return _BarberChatCard(
                                barber: barber,
                                onTap: () {
                                  final me = auth.currentUser!;
                                  final chatId =
                                      (me.uid.compareTo(barber.uid) < 0)
                                      ? '${me.uid}-${barber.uid}'
                                      : '${barber.uid}-${me.uid}';
                                  GoRouter.of(context).push(
                                    AppRouter.kChatView,
                                    extra: {
                                      'myId': me.uid,
                                      'otherUserId': barber.uid,
                                      'otherUserName':
                                          '${barber.firstName} ${barber.lastName}',
                                      'chatId': chatId,
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white.withValues(alpha: .3),
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'لا توجد محادثات بعد',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .4),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

class _BarberChatCard extends StatelessWidget {
  final ProviderServiceModel barber;
  final VoidCallback onTap;
  const _BarberChatCard({required this.barber, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryColor.withValues(alpha: .4),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: barber.profileImage.isNotEmpty
                      ? Image.network(barber.profileImage, fit: BoxFit.cover)
                      : Container(
                          color: Colors.white12,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white38,
                            size: 28,
                          ),
                        ),
                ),
              ),
              if (barber.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D1B2A),
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
                  barber.firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  barber.lastName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.secondaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _Glow(double size, Color color) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: color.withValues(alpha: .12),
  ),
);
