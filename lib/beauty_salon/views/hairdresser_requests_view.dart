import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sehha_app/core/services/fcm_sender.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import '../../core/models/booking_appointment_model.dart';
import '../../core/models/client_model.dart';

const _bg = Color(0xFF0C0810);
const _bgMid = Color(0xFF160F1A);
const _surf = Color(0xFF1C1020);
const _accent = Color(0xFFE91E8C);
const _ac2 = Color(0xFF880E4F);
const _pink = Color(0xFFAD1457);

class HairdresserRequestsView extends StatefulWidget {
  const HairdresserRequestsView({super.key});
  @override
  State<HairdresserRequestsView> createState() =>
      HairdresserRequestsViewState();
}

class HairdresserRequestsViewState extends State<HairdresserRequestsView>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _reqDB = FirebaseDatabase.instance.ref('Requests');

  List<BookingAppointmentModel> _reqs = [];
  bool _loading = true;
  String _filter = 'All';
  late StreamSubscription _sub;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get _todayStr => DateFormat('dd/MM/yyyy').format(DateTime.now());

  static const _filters = [
    ('الكل', 'All', Color(0xFFE91E8C)),
    ('انتظار الرد', 'انتظار الرد', Colors.orange),
    ('مقبول', 'تم القبول', Colors.green),
    ('مرفوض', 'تم الرفض', Colors.red),
    ('مكتمل', 'تمت الخدمة', Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
    _sub = _reqDB.onValue.listen((_) => _load());
  }

  @override
  void dispose() {
    _sub.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || !mounted) return;
    final snap = await _reqDB.orderByChild('reciver').equalTo(uid).once();
    final temp = <BookingAppointmentModel>[];
    if (snap.snapshot.value != null) {
      (snap.snapshot.value as Map).forEach((k, v) {
        final b = BookingAppointmentModel.fromMap(
          Map<String, dynamic>.from(v as Map),
        );
        if (!temp.any((r) => r.id == b.id)) temp.add(b);
      });
      temp.sort((a, b) => b.id.compareTo(a.id));
    }
    if (!mounted) return;
    setState(() {
      _reqs = temp;
      _loading = false;
    });
    _fadeCtrl.forward(from: 0);
  }

  Future<ClientModel> _fetchPatient(String pid) async {
    final s = await FirebaseDatabase.instance.ref('ClientFemales/$pid').get();
    if (s.exists && s.value != null) {
      final d = Map<String, dynamic>.from(s.value as Map);
      return ClientModel(
        uid: pid,
        firstName: d['firstName'] ?? 'غير معروف',
        lastName: d['lastName'] ?? '',
        phoneNumber: d['phoneNumber'] ?? '',
        profileImage: d['profileImage'] ?? '',
        address: d['address'] ?? '',
        email: d['email'] ?? '',
        isOnline: d['isOnline'] ?? false,
        lastSeen: (d['lastSeen'] ?? 0) as int,
        lastMessage: d['lastMessage'] ?? '',
        lastMessageTime: (d['lastMessageTime'] ?? 0) as int,
        unreadMessages: (d['unreadMessages'] ?? 0) as int,
        latitude: (d['latitude'] ?? 0.0).toDouble(),
        longitude: (d['longitude'] ?? 0.0).toDouble(),
      );
    }
    return ClientModel(
      uid: pid,
      firstName: 'غير معروف',
      lastName: '',
      email: '',
      phoneNumber: '',
      profileImage: '',
      address: '',
      isOnline: false,
      lastSeen: 0,
      lastMessage: '',
      lastMessageTime: 0,
      unreadMessages: 0,
      latitude: 0,
      longitude: 0,
    );
  }

  Future<void> _adjustTurn(int delta) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseDatabase.instance.ref(
      'Hairdressers/$uid/dailyTurn/$_todayKey',
    );
    final s = await ref.get();
    final cur = (s.value as int?) ?? 0;
    final upd = (cur + delta).clamp(1, 9999);
    await ref.set(upd);
    HapticFeedback.lightImpact();
    if (delta > 0) await _notifyByTurn(uid, upd);
  }

  Future<void> _updateStatus(BookingAppointmentModel b, String status) async {
    final uid = _auth.currentUser!.uid;

    if (status == 'تمت الخدمة') {
      await _reqDB.child(b.id).update({
        'status': 'تمت الخدمة',
        'ratingStatus': 'انتظار التقييم',
      });
    } else {
      await _reqDB.child(b.id).update({'status': status});
    }

    final tokSnap = await FirebaseDatabase.instance
        .ref('ClientFemales/${b.sender}/fcmToken')
        .get();
    if (!tokSnap.exists) return;
    final tok = tokSnap.value.toString();

    switch (status) {
      case 'تم القبول':
        await FcmSender.send(
          token: tok,
          title: 'تم قبول حجزك ✅',
          body: 'الكوافيرة قبلت حجزك 💅 دورك رقم ${b.turnNumber}',
        );
        break;
      case 'تم الرفض':
        await _decrementTurn(uid);
        await FcmSender.send(
          token: tok,
          title: 'تم رفض الحجز',
          body: 'نعتذر، الكوافيرة غير متاحة حالياً',
        );
        break;
      case 'تمت الخدمة':
        await FcmSender.send(
          token: tok,
          title: 'تمت الخدمة 💅',
          body: 'نتمنى تكوني راضية ❤️ قيّمي تجربتك ⭐',
        );
        await _moveToNextTurn(uid);
        break;
    }
    await _load();
  }

  Future<void> _decrementTurn(String uid) async {
    final ref = FirebaseDatabase.instance.ref(
      'Hairdressers/$uid/dailyTurn/$_todayKey',
    );
    final s = await ref.get();
    final cur = (s.value as int?) ?? 0;
    if (cur > 1) await ref.set(cur - 1);
  }

  Future<void> _moveToNextTurn(String uid) async {
    final ref = FirebaseDatabase.instance.ref(
      'Hairdressers/$uid/dailyTurn/$_todayKey',
    );
    final s = await ref.get();
    int cur = (s.value as int?) ?? 0;
    await ref.set(++cur);
    await _notifyByTurn(uid, cur);
  }

  Future<void> _notifyByTurn(String uid, int cur) async {
    final snap = await _reqDB.orderByChild('reciver').equalTo(uid).get();
    if (!snap.exists) return;
    for (final item in (snap.value as Map).values) {
      final b = BookingAppointmentModel.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
      if (b.status != 'تم القبول') continue;
      if (b.date != _todayStr) continue;
      final tokSnap = await FirebaseDatabase.instance
          .ref('ClientFemales/${b.sender}/fcmToken')
          .get();
      if (!tokSnap.exists) continue;
      final tok = tokSnap.value.toString();
      if (b.turnNumber == cur) {
        await FcmSender.send(
          token: tok,
          title: 'دورك الآن ✨',
          body: 'تفضلي، الكوافيرة مستنياكِ 💅',
        );
      }
      if (b.turnNumber == cur + 1) {
        await FcmSender.send(
          token: tok,
          title: 'استعدي 💅',
          body: 'دورك قرب، حضّري نفسك',
        );
      }
    }
  }

  void _showRatingDlg(BookingAppointmentModel b) {
    double rating = (b.rating ?? 0).toDouble();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .78),
      builder: (_) => StatefulBuilder(
        builder: (ctx, sd) => Dialog(
          backgroundColor: _surf,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تقييم العميلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        sd(() => rating = (i + 1).toDouble());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < rating ? Colors.amber : Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _FBtn(
                  label: 'حفظ التقييم',
                  primary: true,
                  onTap: () async {
                    await _reqDB.child(b.id).update({
                      'rating': rating,
                      'ratingStatus': 'تم التقييم',
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusDlg(BookingAppointmentModel b) {
    String sel = b.status;
    const opts = ['تم القبول', 'تم الرفض', 'تمت الخدمة'];
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .78),
      builder: (_) => StatefulBuilder(
        builder: (ctx, sd) => Dialog(
          backgroundColor: _surf,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.update_rounded,
                    color: _accent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تحديث الحالة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                ...opts.map((s) {
                  final c = _sc(s);
                  final active = sel == s;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      sd(() => sel = s);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? c.withValues(alpha: .12)
                            : Colors.white.withValues(alpha: .04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active
                              ? c.withValues(alpha: .5)
                              : Colors.white.withValues(alpha: .07),
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _si(s),
                            color: active ? c : Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s,
                            style: TextStyle(
                              color: active ? c : Colors.white54,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (active)
                            Icon(
                              Icons.check_circle_rounded,
                              color: c,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _FBtn(
                        label: 'إلغاء',
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FBtn(
                        label: 'تحديث',
                        primary: true,
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _updateStatus(b, sel);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDlg(String id) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .78),
      builder: (_) => Dialog(
        backgroundColor: _surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: .1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: .3),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'حذف الطلب',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'هل أنت متأكدة؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _FBtn(
                      label: 'حذف',
                      danger: true,
                      onTap: () async {
                        await _reqDB.child(id).remove();
                        Navigator.pop(context);
                        setState(() => _reqs.removeWhere((b) => b.id == id));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FBtn(
                      label: 'إلغاء',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _sc(String s) => switch (s) {
    'تم القبول' => const Color(0xFF66BB6A),
    'تم الرفض' => Colors.redAccent,
    'تمت الخدمة' => const Color(0xFF42A5F5),
    _ => const Color(0xFFFFB300),
  };
  IconData _si(String s) => switch (s) {
    'تم القبول' => Icons.check_circle_rounded,
    'تم الرفض' => Icons.cancel_rounded,
    'تمت الخدمة' => Icons.done_all_rounded,
    _ => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
    final filtered = _filter == 'All'
        ? _reqs
        : _reqs.where((r) => r.status == _filter).toList();
    final todayCnt = _reqs.where((r) => r.date == _todayStr).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bgMid, _bg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .5, 1],
                ),
              ),
            ),
            const Positioned(
              top: -80,
              right: -60,
              child: _FGlow(220, _pink, .07),
            ),
            const Positioned(
              bottom: -60,
              left: -50,
              child: _FGlow(190, _accent, .05),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, _ac2],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: .45),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'طلبات الكوافيرة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${_reqs.length} طلب',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .35),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _load,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .08),
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildBanner(uid, todayCnt),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filters.length,
                      itemBuilder: (_, i) {
                        final (label, val, color) = _filters[i];
                        final active = _filter == val;
                        final cnt = val == 'All'
                            ? _reqs.length
                            : _reqs.where((r) => r.status == val).length;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filter = val);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [_accent, _ac2],
                                    )
                                  : null,
                              color: active
                                  ? null
                                  : Colors.white.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? Colors.transparent
                                    : Colors.white.withValues(alpha: .08),
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: _accent.withValues(alpha: .45),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                '$label ($cnt)',
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: .38),
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: _loading
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: _accent,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'جارٍ التحميل...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .3),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : filtered.isEmpty
                        ? _emptyState()
                        : FadeTransition(
                            opacity: _fadeAnim,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final b = filtered[i];
                                return FutureBuilder<ClientModel>(
                                  future: _fetchPatient(b.sender),
                                  builder: (_, snap) {
                                    if (!snap.hasData) return _loadingCard();
                                    final p = snap.data!;
                                    return _HairdresserRequestCard(
                                      booking: b,
                                      patient: p,
                                      onStatus: () => _showStatusDlg(b),
                                      onDelete: () => _showDeleteDlg(b.id),
                                      onRate: b.status == 'تمت الخدمة'
                                          ? () => _showRatingDlg(b)
                                          : null,
                                      onMessage: () {
                                        final uid = _auth.currentUser!.uid;
                                        final chatId = uid.compareTo(p.uid) < 0
                                            ? '$uid-${p.uid}'
                                            : '${p.uid}-$uid';
                                        GoRouter.of(context).push(
                                          AppRouter.kChatView,
                                          extra: {
                                            'myId': uid,
                                            'otherUserId': p.uid,
                                            'otherUserName':
                                                '${p.firstName} ${p.lastName}',
                                            'chatId': chatId,
                                            'isFemaleChat': true,
                                          },
                                        );
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
      ),
    );
  }

  Widget _buildBanner(String uid, int todayCnt) {
    if (uid.isEmpty) return const SizedBox();
    final ref = FirebaseDatabase.instance.ref(
      'Hairdressers/$uid/dailyTurn/$_todayKey',
    );
    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (_, snap) {
        final cur = (snap.data?.snapshot.value as int?) ?? 0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_accent, _ac2],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: .4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white60,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _todayStr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'طلبات اليوم: $todayCnt',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'الدور الحالي: ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .7),
                            fontSize: 12,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Text(
                            '$cur',
                            key: ValueKey(cur),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HTurnBtn(
                    icon: Icons.add_rounded,
                    color: const Color(0xFF69F0AE),
                    onTap: () => _adjustTurn(1),
                  ),
                  const SizedBox(height: 8),
                  _HTurnBtn(
                    icon: Icons.remove_rounded,
                    color: Colors.redAccent,
                    onTap: () => _adjustTurn(-1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accent.withValues(alpha: .06),
            border: Border.all(color: _accent.withValues(alpha: .15)),
          ),
          child: Icon(
            Icons.event_note_rounded,
            color: _accent.withValues(alpha: .38),
            size: 34,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'لا يوجد طلبات',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .24),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'ستظهر الطلبات الجديدة هنا',
          style: TextStyle(color: _accent.withValues(alpha: .38), fontSize: 12),
        ),
      ],
    ),
  );

  Widget _loadingCard() => Container(
    margin: const EdgeInsets.only(bottom: 12),
    height: 90,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .04),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _accent.withValues(alpha: .4),
        ),
      ),
    ),
  );
}

class _HairdresserRequestCard extends StatelessWidget {
  final BookingAppointmentModel booking;
  final ClientModel patient;
  final VoidCallback onStatus, onDelete, onMessage;
  final VoidCallback? onRate;
  const _HairdresserRequestCard({
    required this.booking,
    required this.patient,
    required this.onStatus,
    required this.onDelete,
    required this.onMessage,
    this.onRate,
  });

  Color get _sc => switch (booking.status) {
    'تم القبول' => const Color(0xFF66BB6A),
    'تم الرفض' => Colors.redAccent,
    'تمت الخدمة' => const Color(0xFF42A5F5),
    _ => const Color(0xFFFFB300),
  };
  IconData get _si => switch (booking.status) {
    'تم القبول' => Icons.check_circle_rounded,
    'تم الرفض' => Icons.cancel_rounded,
    'تمت الخدمة' => Icons.done_all_rounded,
    _ => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surf.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _sc.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(color: _sc.withValues(alpha: .07), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accent.withValues(alpha: .4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: .22),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: patient.profileImage.isNotEmpty
                            ? Image.network(
                                patient.profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatar(),
                              )
                            : _avatar(),
                      ),
                    ),
                    if (patient.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A),
                            shape: BoxShape.circle,
                            border: Border.all(color: _bg, width: 2),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white.withValues(alpha: .28),
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.date,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .36),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (patient.phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: Colors.white.withValues(alpha: .2),
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              patient.phoneNumber,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .28),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _sc.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _sc.withValues(alpha: .4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_si, color: _sc, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        booking.status,
                        style: TextStyle(
                          color: _sc,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            height: 1,
            color: Colors.white.withValues(alpha: .05),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.format_list_numbered_rounded,
                    color: _accent.withValues(alpha: .55),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'رقم الدور',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .45),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_accent, _ac2]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: .5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      '${booking.turnNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (booking.description != null && booking.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .05),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      color: Colors.white.withValues(alpha: .22),
                      size: 13,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .42),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if ((booking.rating ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < (booking.rating ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.rating}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _FActionBtn(
                    label: 'تغيير الحالة',
                    icon: Icons.update_rounded,
                    color: _accent,
                    onTap: onStatus,
                  ),
                ),
                const SizedBox(width: 8),
                _FIconBtn(
                  icon: Icons.chat_bubble_rounded,
                  color: const Color(0xFF42A5F5),
                  onTap: onMessage,
                ),
                if (booking.status == 'تمت الخدمة') ...[
                  const SizedBox(width: 8),
                  _FIconBtn(
                    icon: Icons.star_rate_rounded,
                    color: Colors.amber,
                    onTap: onRate ?? () {},
                  ),
                ],
                const SizedBox(width: 8),
                _FIconBtn(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() => Container(
    color: _accent.withValues(alpha: .1),
    child: Center(
      child: Text(
        patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: _accent,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    ),
  );
}

class _HTurnBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _HTurnBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
  );
}

class _FActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Icon(icon, color: color, size: 19),
    ),
  );
}

class _FBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary, danger;
  const _FBtn({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        gradient: primary
            ? const LinearGradient(colors: [_accent, _ac2])
            : null,
        color: danger
            ? Colors.redAccent.withValues(alpha: .1)
            : primary
            ? null
            : Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: danger
              ? Colors.redAccent.withValues(alpha: .35)
              : primary
              ? Colors.transparent
              : Colors.white.withValues(alpha: .08),
        ),
        boxShadow: primary
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: .4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: danger
                ? Colors.redAccent
                : primary
                ? Colors.white
                : Colors.white.withValues(alpha: .5),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}

class _FGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _FGlow(this.size, this.color, this.opacity);
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
