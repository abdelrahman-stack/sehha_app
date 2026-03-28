import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sehha_app/core/services/fcm_sender.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/core/models/provider_service_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlue2 = Color(0xFF1E88E5);
const _kBlueAcc = Color(0xFF64B5F6);

class ServicesMaleDetailsView extends StatefulWidget {
  const ServicesMaleDetailsView({super.key, required this.doctorModel});
  final ProviderServiceModel doctorModel;
  @override
  State<ServicesMaleDetailsView> createState() =>
      _ServicesMaleDetailsViewState();
}

class _ServicesMaleDetailsViewState extends State<ServicesMaleDetailsView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref('Requests');
  final descriptionController = TextEditingController();
  bool barberActive = true;
  late AnimationController _buttonController;
  DateTime? selectedDate;
  int currentTurnNumber = 1;

  @override
  void initState() {
    super.initState();
    checkBarberStatus();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  Future<void> checkBarberStatus() async {
    final snap = await FirebaseDatabase.instance
        .ref('Users/Barbers/${widget.doctorModel.uid}/isActive')
        .get();
    setState(
      () => barberActive = snap.exists ? (snap.value as bool? ?? false) : false,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Stream<int> turnNumberStream(DateTime date) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final barberId = widget.doctorModel.uid;
    final bookingsStream = database
        .orderByChild('reciver')
        .equalTo(barberId)
        .onValue
        .map((e) {
          int count = 0;
          if (e.snapshot.value is Map) {
            (e.snapshot.value as Map).forEach((k, v) {
              if (v is Map && v['date'] == dateStr) count++;
            });
          }
          return count + 1;
        });
    final dailyTurnStream = FirebaseDatabase.instance
        .ref('Barbers/$barberId/dailyTurn/$dateKey')
        .onValue
        .map((e) => (e.snapshot.value as int?) ?? 0);
    return Rx.combineLatest2<int, int, int>(bookingsStream, dailyTurnStream, (
      fromB,
      fromD,
    ) {
      final d = fromD + 1;
      return d > fromB ? d : fromB;
    });
  }

  Future<int> _getFreshTurnNumber(DateTime date) async {
    final barberId = widget.doctorModel.uid;
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final snap = await database.orderByChild('reciver').equalTo(barberId).get();
    int count = 0;
    if (snap.exists && snap.value != null) {
      (snap.value as Map).forEach((k, v) {
        if (v is Map && v['date'] == dateStr) count++;
      });
    }
    final dSnap = await FirebaseDatabase.instance
        .ref('Barbers/$barberId/dailyTurn/$dateKey')
        .get();
    final daily = (dSnap.value as int?) ?? 0;
    final fromB = count + 1;
    final fromD = daily + 1;
    return fromD > fromB ? fromD : fromB;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final today = DateTime.now();
    final next30Days = List.generate(30, (i) => today.add(Duration(days: i)));

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
          Positioned(top: -50, right: -50, child: _G(200, _kBlue)),
          Positioned(bottom: -80, left: -40, child: _G(160, const Color(0xFF0D47A1))),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFF0D1B2A),
                iconTheme: const IconThemeData(color: Colors.white),
                leading: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      GoRouter.of(context).pushReplacement('/DoctorListView');
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  title: Text(
                    t.translate('barber_details'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.doctorModel.profileImage.isNotEmpty
                          ? Image.network(
                              widget.doctorModel.profileImage,
                              fit: BoxFit.cover,
                            )
                          : Container(color: const Color(0xFF0D1B2A)),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0D1B2A).withValues(alpha: .92),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoCard(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.doctorModel.firstName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      widget.doctorModel.lastName,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: .5,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (widget.doctorModel.isActive
                                              ? Colors.greenAccent
                                              : Colors.redAccent)
                                          .withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.doctorModel.isActive
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.doctorModel.isActive
                                          ? 'متاح'
                                          : 'غير متاح',
                                      style: TextStyle(
                                        color: widget.doctorModel.isActive
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!widget.doctorModel.isActive) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(alpha: .3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'الحلاق غير متاح حاليًا',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.doctorModel.address,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .65),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _ContactBtn(
                                  icon: Icons.phone_rounded,
                                  label: 'اتصال',
                                  color: Colors.greenAccent,
                                  onTap: () => makePhoneCall(
                                    widget.doctorModel.phoneNumber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ContactBtn(
                                  icon: Icons.chat_rounded,
                                  label: 'رسالة',
                                  color: Colors.orangeAccent,
                                  onTap: () {
                                    final me = auth.currentUser!;
                                    final otherId = widget.doctorModel.uid;
                                    final chatId =
                                        (me.uid.compareTo(otherId) < 0)
                                        ? '${me.uid}-$otherId'
                                        : '$otherId-${me.uid}';
                                    GoRouter.of(context).push(
                                      AppRouter.kChatView,
                                      extra: {
                                        'myId': me.uid,
                                        'otherUserId': otherId,
                                        'otherUserName':
                                            '${widget.doctorModel.firstName} ${widget.doctorModel.lastName}',
                                        'chatId': chatId,
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ContactBtn(
                                  icon: Icons.map_rounded,
                                  label: 'الخريطة',
                                  color: _kBlueAcc,
                                  onTap: openMap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (widget.doctorModel.services.isNotEmpty) ...[
                        const _SectionLabel('أسعار الخدمات'),
                        const SizedBox(height: 8),
                        _InfoCard(
                          children: [
                            ...widget.doctorModel.services.asMap().entries.map(
                              (e) => Column(
                                children: [
                                  if (e.key > 0)
                                    Divider(
                                      color: Colors.white.withValues(
                                        alpha: .07,
                                      ),
                                      height: 1,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          e.value['name'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${e.value['price']} ج',
                                          style: const TextStyle(
                                            color: _kBlueAcc,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      const _SectionLabel('رقم الدفع (InstaPay / Cash)'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: _kBlueAcc,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.doctorModel.phoneNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: widget.doctorModel.phoneNumber,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ الرقم'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _kBlue.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  color: _kBlueAcc,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const _SectionLabel('اختر اليوم'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 85,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: next30Days.length,
                          itemBuilder: (ctx, i) {
                            final day = next30Days[i];
                            final isSel =
                                selectedDate != null &&
                                day.year == selectedDate!.year &&
                                day.month == selectedDate!.month &&
                                day.day == selectedDate!.day;
                            final isToday =
                                day.year == today.year &&
                                day.month == today.month &&
                                day.day == today.day;
                            return StreamBuilder<int>(
                              stream: turnNumberStream(day),
                              builder: (ctx, snap) {
                                final turn = snap.data ?? 1;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (isSel) {
                                      selectedDate = null;
                                      currentTurnNumber = 1;
                                    } else {
                                      selectedDate = day;
                                      currentTurnNumber = turn;
                                    }
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 78,
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? _kBlue
                                          : (isToday
                                                ? _kBlue.withValues(alpha: .2)
                                                : Colors.white.withValues(
                                                    alpha: .07,
                                                  )),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSel
                                            ? _kBlue2
                                            : (isToday
                                                  ? _kBlue2.withValues(
                                                      alpha: .4,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: .08,
                                                    )),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('EEE', 'ar').format(day),
                                            style: TextStyle(
                                              color: isSel
                                                  ? Colors.white
                                                  : (isToday
                                                        ? _kBlueAcc
                                                        : Colors.white
                                                              .withValues(
                                                                alpha: .6,
                                                              )),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            DateFormat('dd/MM').format(day),
                                            style: TextStyle(
                                              color: isSel
                                                  ? Colors.white
                                                  : Colors.white.withValues(
                                                      alpha: .5,
                                                    ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          if (isSel)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: .25,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'دور $turn',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      const _SectionLabel('تفاصيل الحجز (اختياري)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل أي تفاصيل إضافية...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: .3),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: .07),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: .1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: .1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _kBlue2.withValues(alpha: .7),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _AnimatedGradientBtn(
                        label: 'احجز الآن',
                        icon: Icons.calendar_today_rounded,
                        ctrl: _buttonController,
                        colors: const [_kBlue, _kBlue2],
                        onTap: makeAppointment,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> makePhoneCall(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(' ', '').replaceAll('-', ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openMap() async {
    final lat = widget.doctorModel.latitude;
    final lng = widget.doctorModel.longitude;
    if (lat == 0 || lng == 0) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> makeAppointment() async {
    if (selectedDate == null) {
      _snack('اختر يوم الحجز', Colors.redAccent);
      return;
    }
    final description = descriptionController.text.trim();
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final requestId = database.push().key!;
    final uid = auth.currentUser!.uid;
    final patSnap = await FirebaseDatabase.instance.ref('Clients/$uid').get();
    String uName = 'غير معروف', uImage = '', uPhone = '';
    if (patSnap.exists) {
      final d = Map<String, dynamic>.from(patSnap.value as Map);
      uName = '${d['firstName']} ${d['lastName']}';
      uImage = d['profileImage'] ?? '';
      uPhone = d['phoneNumber'] ?? '';
    }
    final reciverId = widget.doctorModel.uid;
    if (!widget.doctorModel.isActive) {
      _snack('الحلاق غير متاح حالياً', Colors.redAccent);
      return;
    }
    final freshTurn = await _getFreshTurnNumber(selectedDate!);
    database
        .child(requestId)
        .set({
          'date': dateStr,
          'description': description.isEmpty ? null : description,
          'id': requestId,
          'sender': uid,
          'senderPhone': uPhone,
          'senderName': uName,
          'senderImage': uImage,
          'reciver': reciverId,
          'status': 'انتظار الرد',
          'turnNumber': freshTurn,
          'ratingStatus': 'انتظار التقييم',
          'rating': null,
        })
        .then((_) async {
          final bSnap = await FirebaseDatabase.instance
              .ref('Barbers/$reciverId/fcmToken')
              .get();
          final token = bSnap.value as String?;
          if (token != null && token.isNotEmpty) {
            await FcmSender.send(
              token: token,
              title: 'حجز جديد',
              body: 'عميل جديد حجز دور',
            );
          }
          setState(() {
            selectedDate = null;
            descriptionController.clear();
          });
          _snack('تم إرسال الحجز بنجاح!', Colors.green);
        });
  }

  void _snack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
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
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: .55),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: .5,
    ),
  );
}

class _AnimatedGradientBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final AnimationController ctrl;
  final List<Color> colors;
  final VoidCallback onTap;
  const _AnimatedGradientBtn({
    required this.label,
    required this.icon,
    required this.ctrl,
    required this.colors,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => ctrl.forward(),
    onTapUp: (_) {
      ctrl.reverse();
      onTap();
    },
    onTapCancel: () => ctrl.reverse(),
    child: AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Transform.scale(
        scale: 1 - ctrl.value,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: .5),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _G(double s, Color c) => Container(
  width: s,
  height: s,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: c.withValues(alpha: .12),
  ),
);
