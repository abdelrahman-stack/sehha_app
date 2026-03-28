import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_router.dart';
import '../../core/models/provider_service_model.dart';
import '../../core/models/client_model.dart';

const _kAccent = Color(0xFF7EDBD5);
const _kPink2 = Color(0xFF1A8A84);
const _kPink = Color(0xFFEDD49A);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);
const _kSurf = Color(0xFF1C1020);

class CustomerChatList extends StatefulWidget {
  const CustomerChatList({super.key});
  @override
  State<CustomerChatList> createState() => _CustomerChatListState();
}

class _CustomerChatListState extends State<CustomerChatList> {
  final _auth = FirebaseAuth.instance;
  final _chatDB = FirebaseDatabase.instance.ref('chatList');
  final _barberDB = FirebaseDatabase.instance.ref('BeautyCenter');
  late String _uid;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _kDark,
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kDark, _kDark2, _kDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .55, 1],
            ),
          ),
        ),
        const Positioned(top: -70, right: -60, child: _Glow(220, _kPink, .06)),

        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kAccent, _kPink2],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: .4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المحادثات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'مع مراكز التجميل',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder(
                  stream: _chatDB.onValue,
                  builder: (_, snap) {
                    if (!snap.hasData || snap.data!.snapshot.value == null) {
                      return const _EmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'لا توجد محادثات بعد',
                      );
                    }

                    final map = Map<String, dynamic>.from(
                      snap.data!.snapshot.value as Map,
                    );
                    final ids = <String>[];
                    map.forEach((id, patients) {
                      if (Map<String, dynamic>.from(
                        patients as Map,
                      ).containsKey(_uid)) {
                        ids.add(id);
                      }
                    });
                    if (ids.isEmpty) {
                      return const _EmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'لا توجد محادثات بعد',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: ids.length,
                      itemBuilder: (_, i) => FutureBuilder(
                        future: _barberDB.child(ids[i]).once(),
                        builder: (_, bSnap) {
                          if (!bSnap.hasData ||
                              bSnap.data!.snapshot.value == null) {
                            return const SizedBox(height: 72);
                          }
                          final h = ProviderServiceModel.fromMap(
                            Map<String, dynamic>.from(
                              bSnap.data!.snapshot.value as Map,
                            ),
                          );
                          return _ChatTile(
                            name: h.firstName,
                            lastName: h.lastName,
                            image: h.profileImage,
                            isOnline: h.isOnline,
                            onTap: () {
                              final chatId = _uid.compareTo(h.uid) < 0
                                  ? '$_uid-${h.uid}'
                                  : '${h.uid}-$_uid';
                              GoRouter.of(context).push(
                                AppRouter.kChatView,
                                extra: {
                                  'myId': _uid,
                                  'otherUserId': h.uid,
                                  'otherUserName': h.firstName,
                                  'chatId': chatId,
                                  'isFemaleChat': true,
                                },
                              );
                            },
                          );
                        },
                      ),
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

class BeautyCenterChatListView extends StatefulWidget {
  const BeautyCenterChatListView({super.key});
  @override
  State<BeautyCenterChatListView> createState() =>
      _BeautyCenterChatListViewState();
}

class _BeautyCenterChatListViewState extends State<BeautyCenterChatListView> {
  final _auth = FirebaseAuth.instance;
  final _chatDB = FirebaseDatabase.instance.ref('chatList');
  final _patientDB = FirebaseDatabase.instance.ref('Customers');

  List<ClientModel> patients = [];
  bool isLoading = true;
  late String _hId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _hId = user.uid;
      _fetchChatList();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchChatList() async {
    try {
      final event = await _chatDB.child(_hId).once();
      final temp = <ClientModel>[];
      if (event.snapshot.value != null) {
        for (final id in (event.snapshot.value as Map).keys) {
          final pe = await _patientDB.child(id as String).once();
          if (pe.snapshot.value != null) {
            temp.add(
              ClientModel.fromMap(
                Map<String, dynamic>.from(pe.snapshot.value as Map),
              ),
            );
          }
        }
      }
      setState(() {
        patients = temp;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _kDark,
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kDark, _kDark2, _kDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .55, 1],
            ),
          ),
        ),
        const Positioned(top: -70, right: -60, child: _Glow(220, _kPink, .06)),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kAccent, _kPink2],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: .4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'العملاء',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${patients.length} محادثة',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .35),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _kAccent,
                          strokeWidth: 2.5,
                        ),
                      )
                    : patients.isEmpty
                    ? const _EmptyState(
                        icon: Icons.people_outline_rounded,
                        label: 'لا يوجد محادثات',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: patients.length,
                        itemBuilder: (_, i) {
                          final p = patients[i];
                          return _ChatTile(
                            name: p.firstName,
                            lastName: p.lastName,
                            image: p.profileImage,
                            isOnline: p.isOnline,
                            subtitle: p.email,
                            onTap: () {
                              final uid = _auth.currentUser!.uid;
                              final chatId = uid.compareTo(p.uid) < 0
                                  ? '$uid-${p.uid}'
                                  : '${p.uid}-$uid';
                              GoRouter.of(context).push(
                                AppRouter.kChatView,
                                extra: {
                                  'myId': uid,
                                  'otherUserId': p.uid,
                                  'otherUserName': p.firstName,
                                  'chatId': chatId,
                                  'isFemaleChat': true,
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

class _ChatTile extends StatelessWidget {
  final String name, lastName, image;
  final String? subtitle;
  final bool isOnline;
  final VoidCallback onTap;
  const _ChatTile({
    required this.name,
    required this.lastName,
    required this.image,
    required this.isOnline,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _kSurf.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kAccent.withValues(alpha: .35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: .15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _av(name),
                        )
                      : _av(name),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF66BB6A),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kDark, width: 2),
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
                  '$name $lastName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .35),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kAccent.withValues(alpha: .25)),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kAccent,
              size: 13,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _av(String n) => Container(
    color: _kAccent.withValues(alpha: .1),
    child: Center(
      child: Text(
        n.isNotEmpty ? n[0].toUpperCase() : '?',
        style: const TextStyle(
          color: _kAccent,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kAccent.withValues(alpha: .06),
            border: Border.all(color: _kAccent.withValues(alpha: .14)),
          ),
          child: Icon(icon, color: _kAccent.withValues(alpha: .38), size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .24),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Glow(this.size, this.color, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}
