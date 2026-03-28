import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../core/models/client_model.dart';
import '../../widgets/lottie_loading_Indicator.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_router.dart';
import 'package:go_router/go_router.dart';

class BarberChatListView extends StatefulWidget {
  const BarberChatListView({super.key});
  @override
  State<BarberChatListView> createState() => _BarberChatListViewState();
}

class _BarberChatListViewState extends State<BarberChatListView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference chatListDB = FirebaseDatabase.instance.ref(
    'chatList',
  );
  final DatabaseReference patientDB = FirebaseDatabase.instance.ref('Clients');
  List<ClientModel> customers = [];
  bool isLoading = true;
  late String barberId;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    final user = auth.currentUser;
    if (user != null) {
      barberId = user.uid;
      fetchChatList();
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchChatList() async {
    try {
      final snap = await chatListDB.child(barberId).once();
      final List<ClientModel> temp = [];
      if (snap.snapshot.value != null) {
        final map = snap.snapshot.value as Map<dynamic, dynamic>;
        for (final id in map.keys) {
          final pSnap = await patientDB.child(id).once();
          if (pSnap.snapshot.value != null) {
            temp.add(
              ClientModel.fromMap(
                Map<String, dynamic>.from(pSnap.snapshot.value as Map),
              ),
            );
          }
        }
      }
      if (!mounted) return;
      setState(() {
        customers = temp;
        isLoading = false;
      });
      _fadeCtrl.forward();
    } catch (_) {
      setState(() => isLoading = false);
    }
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
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'المحادثات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: isLoading
                      ? const Center(child: CustomCircularProgressIndicator())
                      : customers.isEmpty
                      ? _buildEmpty()
                      : FadeTransition(
                          opacity: _fadeAnim,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: customers.length,
                            itemBuilder: (ctx, i) {
                              final p = customers[i];
                              return _ChatCard(
                                patient: p,
                                onTap: () {
                                  final myId = auth.currentUser!.uid;
                                  final chatId = (myId.compareTo(p.uid) < 0)
                                      ? '$myId-${p.uid}'
                                      : '${p.uid}-$myId';
                                  GoRouter.of(context).push(
                                    AppRouter.kChatView,
                                    extra: {
                                      'myId': myId,
                                      'otherUserId': p.uid,
                                      'otherUserName': p.firstName,
                                      'chatId': chatId,
                                    },
                                  );
                                },
                              );
                            },
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
          'لا يوجد محادثات',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .4),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

class _ChatCard extends StatelessWidget {
  final ClientModel patient;
  final VoidCallback onTap;
  const _ChatCard({required this.patient, required this.onTap});

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
                  child: patient.profileImage.isNotEmpty
                      ? Image.network(patient.profileImage, fit: BoxFit.cover)
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
              if (patient.isOnline)
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
                  '${patient.firstName} ${patient.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  patient.phoneNumber,
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
