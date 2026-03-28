// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:sehha_app/core/services/fcm_sender.dart';
// import 'package:sehha_app/core/tools/app_localizations%20.dart';
// import 'package:sehha_app/core/utils/app_router.dart';
// import 'package:sehha_app/core/models/provider_service_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:url_launcher/url_launcher.dart';

// const _kAccent = Color(0xFF7EDBD5);
// const _kPink2 = Color(0xFF1A8A84);
// const _kPink = Color(0xFFEDD49A);
// const _kDark = Color(0xFF0C0810);
// const _kDark2 = Color(0xFF160F1A);

// class BeautyCenterDetailsView extends StatefulWidget {
//   const BeautyCenterDetailsView({super.key, required this.serviceModel});
//   final ProviderServiceModel serviceModel;
//   @override
//   State<BeautyCenterDetailsView> createState() =>
//       _BeautyCenterDetailsViewState();
// }

// class _BeautyCenterDetailsViewState extends State<BeautyCenterDetailsView>
//     with SingleTickerProviderStateMixin {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final DatabaseReference database = FirebaseDatabase.instance.ref('Requests');
//   final descriptionController = TextEditingController();
//   bool barberActive = true;
//   late AnimationController _buttonController;
//   DateTime? selectedDate;
//   int currentTurnNumber = 1;

//   @override
//   void initState() {
//     super.initState();
//     checkBarberStatus();
//     _buttonController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//       lowerBound: 0.0,
//       upperBound: 0.05,
//     );
//   }

//   Future<void> checkBarberStatus() async {
//     final snap = await FirebaseDatabase.instance
//         .ref('Users/BeautyCenter/${widget.serviceModel.uid}/isActive')
//         .get();
//     setState(
//       () => barberActive = snap.exists ? (snap.value as bool? ?? false) : false,
//     );
//   }

//   @override
//   void dispose() {
//     _buttonController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }

//   Stream<int> turnNumberStream(DateTime date) {
//     final dateStr = DateFormat('dd/MM/yyyy').format(date);
//     final dateKey = DateFormat('yyyy-MM-dd').format(date);
//     final barberId = widget.serviceModel.uid;
//     final bookingsStream = database
//         .orderByChild('reciver')
//         .equalTo(barberId)
//         .onValue
//         .map((e) {
//           int count = 0;
//           if (e.snapshot.value is Map) {
//             (e.snapshot.value as Map).forEach((k, v) {
//               if (v is Map && v['date'] == dateStr) count++;
//             });
//           }
//           return count + 1;
//         });
//     final dailyTurnStream = FirebaseDatabase.instance
//         .ref('BeautyCenter/$barberId/dailyTurn/$dateKey')
//         .onValue
//         .map((e) => (e.snapshot.value as int?) ?? 0);
//     return Rx.combineLatest2<int, int, int>(bookingsStream, dailyTurnStream, (
//       fromB,
//       fromD,
//     ) {
//       final d = fromD + 1;
//       return d > fromB ? d : fromB;
//     });
//   }

//   Future<int> _getFreshTurnNumber(DateTime date) async {
//     final beautyCenterId = widget.serviceModel.uid;
//     final dateStr = DateFormat('dd/MM/yyyy').format(date);
//     final dateKey = DateFormat('yyyy-MM-dd').format(date);
//     final snap = await database
//         .orderByChild('reciver')
//         .equalTo(beautyCenterId)
//         .get();
//     int count = 0;
//     if (snap.exists && snap.value != null) {
//       (snap.value as Map).forEach((k, v) {
//         if (v is Map && v['date'] == dateStr) count++;
//       });
//     }
//     final dSnap = await FirebaseDatabase.instance
//         .ref('BeautyCenter/$beautyCenterId/dailyTurn/$dateKey')
//         .get();
//     final daily = (dSnap.value as int?) ?? 0;
//     final fromB = count + 1;
//     final fromD = daily + 1;
//     return fromD > fromB ? fromD : fromB;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context);
//     final today = DateTime.now();
//     final next30Days = List.generate(30, (i) => today.add(Duration(days: i)));

//     return Scaffold(
//       backgroundColor: _kDark,
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_kDark, _kDark2, _kDark],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           Positioned(top: -50, right: -50, child: _G(200, _kAccent)),
//           Positioned(bottom: -80, left: -40, child: _G(160, _kAccent)),

//           CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 220,
//                 pinned: true,
//                 backgroundColor: _kAccent.withValues(alpha: .9),
//                 iconTheme: const IconThemeData(color: Colors.white),
//                 leading: GestureDetector(
//                   onTap: () {
//                     if (Navigator.of(context).canPop()) {
//                       context.pop();
//                     } else {}
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _kDark.withValues(alpha: .3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.arrow_back_ios_new,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//                 flexibleSpace: FlexibleSpaceBar(
//                   titlePadding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
//                   title: Text(
//                     t.translate('تفاصيل مركز التجميل'),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   background: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       widget.serviceModel.profileImage.isNotEmpty
//                           ? Image.network(
//                               widget.serviceModel.profileImage,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(color: _kDark),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.transparent,
//                               _kDark.withValues(alpha: .92),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _InfoCard(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       widget.serviceModel.firstName,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w900,
//                                       ),
//                                     ),
//                                     Text(
//                                       widget.serviceModel.lastName,
//                                       style: TextStyle(
//                                         color: Colors.white.withValues(
//                                           alpha: .5,
//                                         ),
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       (widget.serviceModel.isActive
//                                               ? Colors.greenAccent
//                                               : Colors.redAccent)
//                                           .withValues(alpha: .15),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Container(
//                                       width: 7,
//                                       height: 7,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: widget.serviceModel.isActive
//                                             ? Colors.greenAccent
//                                             : Colors.redAccent,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       widget.serviceModel.isActive
//                                           ? 'متاح'
//                                           : 'غير متاح',
//                                       style: TextStyle(
//                                         color: widget.serviceModel.isActive
//                                             ? Colors.greenAccent
//                                             : Colors.redAccent,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (!widget.serviceModel.isActive) ...[
//                             const SizedBox(height: 10),
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.withValues(alpha: .08),
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.redAccent.withValues(alpha: .3),
//                                 ),
//                               ),
//                               child: const Row(
//                                 children: [
//                                   Icon(
//                                     Icons.info_outline_rounded,
//                                     color: Colors.redAccent,
//                                     size: 16,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       'مركز التجميل غير متاح حاليًا',
//                                       style: TextStyle(
//                                         color: Colors.redAccent,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                           const SizedBox(height: 14),
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.location_on_rounded,
//                                 color: Colors.redAccent,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 6),
//                               Expanded(
//                                 child: Text(
//                                   widget.serviceModel.address,
//                                   style: TextStyle(
//                                     color: Colors.white.withValues(alpha: .65),
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 14),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _ContactBtn(
//                                   icon: Icons.phone_rounded,
//                                   label: 'اتصال',
//                                   color: Colors.greenAccent,
//                                   onTap: () => makePhoneCall(
//                                     widget.serviceModel.phoneNumber,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _ContactBtn(
//                                   icon: Icons.chat_rounded,
//                                   label: 'رسالة',
//                                   color: Colors.orangeAccent,
//                                   onTap: () {
//                                     final me = auth.currentUser!;
//                                     final otherId = widget.serviceModel.uid;
//                                     final chatId =
//                                         (me.uid.compareTo(otherId) < 0)
//                                         ? '${me.uid}-$otherId'
//                                         : '$otherId-${me.uid}';
//                                     GoRouter.of(context).push(
//                                       AppRouter.kChatView,
//                                       extra: {
//                                         'myId': me.uid,
//                                         'otherUserId': otherId,
//                                         'otherUserName':
//                                             '${widget.serviceModel.firstName} ${widget.serviceModel.lastName}',
//                                         'chatId': chatId,
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _ContactBtn(
//                                   icon: Icons.map_rounded,
//                                   label: 'الخريطة',
//                                   color: _kPink,
//                                   onTap: openMap,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 14),

//                       if (widget.serviceModel.services.isNotEmpty) ...[
//                         const _SectionLabel('أسعار الخدمات'),
//                         const SizedBox(height: 8),
//                         _InfoCard(
//                           children: [
//                             ...widget.serviceModel.services.asMap().entries.map(
//                               (e) => Column(
//                                 children: [
//                                   if (e.key > 0)
//                                     Divider(
//                                       color: Colors.white.withValues(
//                                         alpha: .07,
//                                       ),
//                                       height: 1,
//                                     ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           e.value['name'] ?? '',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         Text(
//                                           '${e.value['price']} ج',
//                                           style: const TextStyle(
//                                             color: _kPink,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 14),
//                       ],

//                       const _SectionLabel('رقم الدفع (InstaPay / Cash)'),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: .06),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Colors.white.withValues(alpha: .08),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.account_balance_wallet_outlined,
//                               color: _kPink,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 widget.serviceModel.phoneNumber,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   letterSpacing: 1,
//                                 ),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Clipboard.setData(
//                                   ClipboardData(
//                                     text: widget.serviceModel.phoneNumber,
//                                   ),
//                                 );
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('تم نسخ الرقم'),
//                                     duration: Duration(seconds: 2),
//                                     behavior: SnackBarBehavior.floating,
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 width: 34,
//                                 height: 34,
//                                 decoration: BoxDecoration(
//                                   color: _kAccent.withValues(alpha: .2),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(
//                                   Icons.copy_rounded,
//                                   color: _kPink,
//                                   size: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       const _SectionLabel('اختر اليوم'),
//                       const SizedBox(height: 10),
//                       SizedBox(
//                         height: 85,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: next30Days.length,
//                           itemBuilder: (ctx, i) {
//                             final day = next30Days[i];
//                             final isSel =
//                                 selectedDate != null &&
//                                 day.year == selectedDate!.year &&
//                                 day.month == selectedDate!.month &&
//                                 day.day == selectedDate!.day;
//                             final isToday =
//                                 day.year == today.year &&
//                                 day.month == today.month &&
//                                 day.day == today.day;
//                             return StreamBuilder<int>(
//                               stream: turnNumberStream(day),
//                               builder: (ctx, snap) {
//                                 final turn = snap.data ?? 1;
//                                 return GestureDetector(
//                                   onTap: () => setState(() {
//                                     if (isSel) {
//                                       selectedDate = null;
//                                       currentTurnNumber = 1;
//                                     } else {
//                                       selectedDate = day;
//                                       currentTurnNumber = turn;
//                                     }
//                                   }),
//                                   child: AnimatedContainer(
//                                     duration: const Duration(milliseconds: 250),
//                                     margin: const EdgeInsets.only(right: 10),
//                                     width: 78,
//                                     decoration: BoxDecoration(
//                                       color: isSel
//                                           ? _kAccent
//                                           : (isToday
//                                                 ? _kAccent.withValues(alpha: .2)
//                                                 : Colors.white.withValues(
//                                                     alpha: .07,
//                                                   )),
//                                       borderRadius: BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: isSel
//                                             ? _kAccent.withValues(alpha: .8)
//                                             : (isToday
//                                                   ? _kAccent.withValues(
//                                                       alpha: .4,
//                                                     )
//                                                   : Colors.white.withValues(
//                                                       alpha: .08,
//                                                     )),
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(6),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             DateFormat('EEE', 'ar').format(day),
//                                             style: TextStyle(
//                                               color: isSel
//                                                   ? Colors.white
//                                                   : (isToday
//                                                         ? _kPink
//                                                         : Colors.white
//                                                               .withValues(
//                                                                 alpha: .6,
//                                                               )),
//                                               fontWeight: FontWeight.w700,
//                                               fontSize: 11,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           Text(
//                                             DateFormat('dd/MM').format(day),
//                                             style: TextStyle(
//                                               color: isSel
//                                                   ? Colors.white
//                                                   : Colors.white.withValues(
//                                                       alpha: .5,
//                                                     ),
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 3),
//                                           if (isSel)
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 5,
//                                                     vertical: 1,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withValues(
//                                                   alpha: .25,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                               ),
//                                               child: Text(
//                                                 'دور $turn',
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.w800,
//                                                 ),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       const _SectionLabel('تفاصيل الحجز (اختياري)'),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: descriptionController,
//                         maxLines: 3,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'أدخل أي تفاصيل إضافية...',
//                           hintStyle: TextStyle(
//                             color: Colors.white.withValues(alpha: .3),
//                             fontSize: 13,
//                           ),
//                           filled: true,
//                           fillColor: Colors.white.withValues(alpha: .07),
//                           contentPadding: const EdgeInsets.all(14),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                             borderSide: BorderSide(
//                               color: Colors.white.withValues(alpha: .1),
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                             borderSide: BorderSide(
//                               color: Colors.white.withValues(alpha: .1),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                             borderSide: BorderSide(
//                               color: _kPink2.withValues(alpha: .7),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       _AnimatedGradientBtn(
//                         label: 'احجز الآن',
//                         icon: Icons.calendar_today_rounded,
//                         ctrl: _buttonController,
//                         colors: const [_kAccent, _kPink2],
//                         onTap: makeAppointment,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> makePhoneCall(String phone) async {
//     final uri = Uri(
//       scheme: 'tel',
//       path: phone.replaceAll(' ', '').replaceAll('-', ''),
//     );
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   Future<void> openMap() async {
//     final lat = widget.serviceModel.latitude;
//     final lng = widget.serviceModel.longitude;
//     if (lat == 0 || lng == 0) return;
//     final uri = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   Future<void> makeAppointment() async {
//     if (selectedDate == null) {
//       _snack('اختر يوم الحجز', Colors.redAccent);
//       return;
//     }
//     final description = descriptionController.text.trim();
//     final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
//     final requestId = database.push().key!;
//     final uid = auth.currentUser!.uid;
//     final patSnap = await FirebaseDatabase.instance.ref('Customers/$uid').get();
//     String uName = 'غير معروف', uImage = '', uPhone = '';
//     if (patSnap.exists) {
//       final d = Map<String, dynamic>.from(patSnap.value as Map);
//       uName = '${d['firstName']} ${d['lastName']}';
//       uImage = d['profileImage'] ?? '';
//       uPhone = d['phoneNumber'] ?? '';
//     }
//     final reciverId = widget.serviceModel.uid;
//     if (!widget.serviceModel.isActive) {
//       _snack('الكوافير غير متاح حالياً', Colors.redAccent);
//       return;
//     }
//     final freshTurn = await _getFreshTurnNumber(selectedDate!);
//     database
//         .child(requestId)
//         .set({
//           'date': dateStr,
//           'description': description.isEmpty ? null : description,
//           'id': requestId,
//           'sender': uid,
//           'senderPhone': uPhone,
//           'senderName': uName,
//           'senderImage': uImage,
//           'reciver': reciverId,
//           'status': 'انتظار الرد',
//           'turnNumber': freshTurn,
//           'ratingStatus': 'انتظار التقييم',
//           'rating': null,
//         })
//         .then((_) async {
//           final bSnap = await FirebaseDatabase.instance
//               .ref('BeautyCenter/$reciverId/fcmToken')
//               .get();
//           final token = bSnap.value as String?;
//           if (token != null && token.isNotEmpty) {
//             await FcmSender.send(
//               token: token,
//               title: 'حجز جديد 💅',
//               body: 'عميل جديد حجز – دوره رقم $currentTurnNumber',
//             );
//           }
//           setState(() {
//             selectedDate = null;
//             descriptionController.clear();
//           });
//           _snack('تم إرسال الحجز بنجاح 🎉', Colors.green);
//         });
//   }

//   void _snack(String msg, Color color) =>
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           backgroundColor: color,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
// }

// class _InfoCard extends StatelessWidget {
//   final List<Widget> children;
//   const _InfoCard({required this.children});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white.withValues(alpha: .06),
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: Colors.white.withValues(alpha: .08)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: children,
//     ),
//   );
// }

// class _ContactBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ContactBtn({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       height: 42,
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: .12),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withValues(alpha: .3)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 16),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: color,
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);
//   @override
//   Widget build(BuildContext context) => Text(
//     text,
//     style: TextStyle(
//       color: Colors.white.withValues(alpha: .55),
//       fontSize: 12,
//       fontWeight: FontWeight.w600,
//       letterSpacing: .5,
//     ),
//   );
// }

// class _AnimatedGradientBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final AnimationController ctrl;
//   final List<Color> colors;
//   final VoidCallback onTap;
//   const _AnimatedGradientBtn({
//     required this.label,
//     required this.icon,
//     required this.ctrl,
//     required this.colors,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTapDown: (_) => ctrl.forward(),
//     onTapUp: (_) {
//       ctrl.reverse();
//       onTap();
//     },
//     onTapCancel: () => ctrl.reverse(),
//     child: AnimatedBuilder(
//       animation: ctrl,
//       builder: (_, __) => Transform.scale(
//         scale: 1 - ctrl.value,
//         child: Container(
//           height: 56,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: colors),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: colors[0].withValues(alpha: .5),
//                 blurRadius: 16,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 18),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _G(double s, Color c) => Container(
//   width: s,
//   height: s,
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     color: c.withValues(alpha: .12),
//   ),
// );





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

const _kAccent = Color(0xFF7EDBD5);
const _kPink2 = Color(0xFF1A8A84);
const _kPink = Color(0xFFEDD49A);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);

// ─── Day names Arabic ───────────────────────────────────────────────────────
const _kDayNames = {
  1: 'الاثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
  6: 'السبت',
  7: 'الأحد',
};

class BeautyCenterDetailsView extends StatefulWidget {
  const BeautyCenterDetailsView({super.key, required this.serviceModel});
  final ProviderServiceModel serviceModel;
  @override
  State<BeautyCenterDetailsView> createState() =>
      _BeautyCenterDetailsViewState();
}

class _BeautyCenterDetailsViewState extends State<BeautyCenterDetailsView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref('Requests');
  final descriptionController = TextEditingController();
  bool barberActive = true;
  late AnimationController _buttonController;
  DateTime? selectedDate;
  int currentTurnNumber = 1;

  // ── medical reps ──
  List<Map<String, dynamic>> _allDoctors = [];
  int _selectedDayTab = DateTime.now().weekday; // 1=Mon … 7=Sun

  @override
  void initState() {
    super.initState();
    checkBarberStatus();
    _loadDoctors();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  Future<void> checkBarberStatus() async {
    final snap = await FirebaseDatabase.instance
        .ref('Users/BeautyCenter/${widget.serviceModel.uid}/isActive')
        .get();
    setState(
      () => barberActive = snap.exists ? (snap.value as bool? ?? false) : false,
    );
  }

  Future<void> _loadDoctors() async {
    FirebaseDatabase.instance
        .ref('BeautyCenter/${widget.serviceModel.uid}/doctors')
        .onValue
        .listen((event) {
      if (!mounted) return;
      final List<Map<String, dynamic>> list = [];
      if (event.snapshot.value is List) {
        for (final item in (event.snapshot.value as List)) {
          if (item != null) list.add(Map<String, dynamic>.from(item as Map));
        }
      } else if (event.snapshot.value is Map) {
        (event.snapshot.value as Map).forEach((_, v) {
          if (v is Map) list.add(Map<String, dynamic>.from(v));
        });
      }
      setState(() => _allDoctors = list);
    });
  }

  List<Map<String, dynamic>> get _doctorsForSelectedDay => _allDoctors
      .where((d) => (d['day'] as int?) == _selectedDayTab)
      .toList();

  @override
  void dispose() {
    _buttonController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Stream<int> turnNumberStream(DateTime date) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final barberId = widget.serviceModel.uid;
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
        .ref('BeautyCenter/$barberId/dailyTurn/$dateKey')
        .onValue
        .map((e) => (e.snapshot.value as int?) ?? 0);
    return Rx.combineLatest2<int, int, int>(bookingsStream, dailyTurnStream,
        (fromB, fromD) {
      final d = fromD + 1;
      return d > fromB ? d : fromB;
    });
  }

  Future<int> _getFreshTurnNumber(DateTime date) async {
    final beautyCenterId = widget.serviceModel.uid;
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final snap = await database
        .orderByChild('reciver')
        .equalTo(beautyCenterId)
        .get();
    int count = 0;
    if (snap.exists && snap.value != null) {
      (snap.value as Map).forEach((k, v) {
        if (v is Map && v['date'] == dateStr) count++;
      });
    }
    final dSnap = await FirebaseDatabase.instance
        .ref('BeautyCenter/$beautyCenterId/dailyTurn/$dateKey')
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
      backgroundColor: _kDark,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kDark, _kDark2, _kDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(top: -50, right: -50, child: _G(200, _kAccent)),
          Positioned(bottom: -80, left: -40, child: _G(160, _kAccent)),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _kAccent.withValues(alpha: .9),
                iconTheme: const IconThemeData(color: Colors.white),
                leading: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kDark.withValues(alpha: .3),
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
                    t.translate('تفاصيل مركز التجميل'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.serviceModel.profileImage.isNotEmpty
                          ? Image.network(
                              widget.serviceModel.profileImage,
                              fit: BoxFit.cover,
                            )
                          : Container(color: _kDark),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _kDark.withValues(alpha: .92),
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
                                      widget.serviceModel.firstName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      widget.serviceModel.lastName,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                            alpha: .5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (widget.serviceModel.isActive
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
                                        color: widget.serviceModel.isActive
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.serviceModel.isActive
                                          ? 'متاح'
                                          : 'غير متاح',
                                      style: TextStyle(
                                        color: widget.serviceModel.isActive
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
                          if (!widget.serviceModel.isActive) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color:
                                        Colors.redAccent.withValues(alpha: .3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: Colors.redAccent, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'مركز التجميل غير متاح حاليًا',
                                      style: TextStyle(
                                          color: Colors.redAccent, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Colors.redAccent, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.serviceModel.address,
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
                                      widget.serviceModel.phoneNumber),
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
                                    final otherId = widget.serviceModel.uid;
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
                                            '${widget.serviceModel.firstName} ${widget.serviceModel.lastName}',
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
                                  color: _kPink,
                                  onTap: openMap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (widget.serviceModel.services.isNotEmpty) ...[
                        const _SectionLabel('أسعار الخدمات'),
                        const SizedBox(height: 8),
                        _InfoCard(
                          children: [
                            ...widget.serviceModel.services.asMap().entries.map(
                              (e) => Column(
                                children: [
                                  if (e.key > 0)
                                    Divider(
                                        color:
                                            Colors.white.withValues(alpha: .07),
                                        height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                            color: _kPink,
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
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: .08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: _kPink,
                                size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.serviceModel.phoneNumber,
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
                                Clipboard.setData(ClipboardData(
                                    text: widget.serviceModel.phoneNumber));
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
                                  color: _kAccent.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.copy_rounded,
                                    color: _kPink, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (_allDoctors.isNotEmpty) ...[
                        _MedicalRepsHeader(doctorCount: _allDoctors.length),
                        const SizedBox(height: 12),
                        _DayTabBar(
                          selectedDay: _selectedDayTab,
                          onDaySelected: (d) =>
                              setState(() => _selectedDayTab = d),
                          activeDays: _allDoctors
                              .map((d) => d['day'] as int? ?? 0)
                              .toSet(),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _doctorsForSelectedDay.isEmpty
                              ? _EmptyDayCard(
                                  key: ValueKey(_selectedDayTab),
                                  dayName:
                                      _kDayNames[_selectedDayTab] ?? '',
                                )
                              : Column(
                                  key: ValueKey(_selectedDayTab),
                                  children: _doctorsForSelectedDay
                                      .asMap()
                                      .entries
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: _DoctorCard(
                                              doctor: e.value,
                                              index: e.key,
                                            ),
                                          ))
                                      .toList(),
                                ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const SizedBox(height: 6),

                      const _SectionLabel('اختر اليوم'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 85,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: next30Days.length,
                          itemBuilder: (ctx, i) {
                            final day = next30Days[i];
                            final isSel = selectedDate != null &&
                                day.year == selectedDate!.year &&
                                day.month == selectedDate!.month &&
                                day.day == selectedDate!.day;
                            final isToday = day.year == today.year &&
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
                                    duration:
                                        const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 78,
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? _kAccent
                                          : (isToday
                                              ? _kAccent.withValues(alpha: .2)
                                              : Colors.white
                                                  .withValues(alpha: .07)),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSel
                                            ? _kAccent.withValues(alpha: .8)
                                            : (isToday
                                                ? _kAccent
                                                    .withValues(alpha: .4)
                                                : Colors.white
                                                    .withValues(alpha: .08)),
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
                                            DateFormat('EEE', 'ar')
                                                .format(day),
                                            style: TextStyle(
                                              color: isSel
                                                  ? Colors.white
                                                  : (isToday
                                                      ? _kPink
                                                      : Colors.white
                                                          .withValues(
                                                              alpha: .6)),
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
                                                      alpha: .5),
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
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: .25),
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
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'أدخل أي تفاصيل إضافية...',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: .3),
                              fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: .07),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: .1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: .1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: _kPink2.withValues(alpha: .7),
                                width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _AnimatedGradientBtn(
                        label: 'احجز الآن',
                        icon: Icons.calendar_today_rounded,
                        ctrl: _buttonController,
                        colors: const [_kAccent, _kPink2],
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
        path: phone.replaceAll(' ', '').replaceAll('-', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openMap() async {
    final lat = widget.serviceModel.latitude;
    final lng = widget.serviceModel.longitude;
    if (lat == 0 || lng == 0) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
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
    final patSnap =
        await FirebaseDatabase.instance.ref('Customers/$uid').get();
    String uName = 'غير معروف', uImage = '', uPhone = '';
    if (patSnap.exists) {
      final d = Map<String, dynamic>.from(patSnap.value as Map);
      uName = '${d['firstName']} ${d['lastName']}';
      uImage = d['profileImage'] ?? '';
      uPhone = d['phoneNumber'] ?? '';
    }
    final reciverId = widget.serviceModel.uid;
    if (!widget.serviceModel.isActive) {
      _snack('الكوافير غير متاح حالياً', Colors.redAccent);
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
              .ref('BeautyCenter/$reciverId/fcmToken')
              .get();
          final token = bSnap.value as String?;
          if (token != null && token.isNotEmpty) {
            await FcmSender.send(
              token: token,
              title: 'حجز جديد 💅',
              body: 'عميل جديد حجز – دوره رقم $currentTurnNumber',
            );
          }
          setState(() {
            selectedDate = null;
            descriptionController.clear();
          });
          _snack('تم إرسال الحجز بنجاح 🎉', Colors.green);
        });
  }

  void _snack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

class _MedicalRepsHeader extends StatelessWidget {
  final int doctorCount;
  const _MedicalRepsHeader({required this.doctorCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kAccent, _kPink2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: .35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.medical_services_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الأطباء والمختصون',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$doctorCount طبيب / مختص متاح هذا الأسبوع',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kAccent.withValues(alpha: .3)),
          ),
          child: const Text(
            'أسبوعي',
            style: TextStyle(
              color: _kAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayTabBar extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final Set<int> activeDays;

  const _DayTabBar({
    required this.selectedDay,
    required this.onDaySelected,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final day = i + 1; // 1=Mon … 7=Sun
          final isSel = day == selectedDay;
          final isToday = day == todayWeekday;
          final hasDoc = activeDays.contains(day);
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSel
                    ? const LinearGradient(
                        colors: [_kAccent, _kPink2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSel
                    ? null
                    : (isToday
                        ? _kAccent.withValues(alpha: .15)
                        : Colors.white.withValues(alpha: .06)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel
                      ? Colors.transparent
                      : (isToday
                          ? _kAccent.withValues(alpha: .4)
                          : Colors.white.withValues(alpha: .08)),
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: _kAccent.withValues(alpha: .4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _kDayNames[day] ?? '',
                    style: TextStyle(
                      color: isSel
                          ? Colors.white
                          : (isToday
                              ? _kPink
                              : Colors.white.withValues(alpha: .6)),
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  if (hasDoc) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel
                            ? Colors.white.withValues(alpha: .8)
                            : _kAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final int index;
  const _DoctorCard({required this.doctor, required this.index});

  static const List<Color> _specialtyColors = [
    Color(0xFF7EDBD5),
    Color(0xFFEDD49A),
    Color(0xFF9B8FD9),
    Color(0xFF6BD48A),
    Color(0xFFE88C7D),
  ];

  @override
  Widget build(BuildContext context) {
    final accentColor = _specialtyColors[index % _specialtyColors.length];
    final name = doctor['name'] as String? ?? 'طبيب';
    final specialty = doctor['specialty'] as String? ?? 'تخصص عام';
    final from = doctor['from'] as String? ?? '';
    final to = doctor['to'] as String? ?? '';
    final hasTime = from.isNotEmpty && to.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: .2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: .07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: .3),
                  accentColor.withValues(alpha: .1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: accentColor.withValues(alpha: .5), width: 1.5),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : 'د',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'د. $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 12, color: accentColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        specialty,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasTime) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: .3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: accentColor),
                      const SizedBox(width: 3),
                      Text(
                        from,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '–',
                    style: TextStyle(
                        color: accentColor.withValues(alpha: .6),
                        fontSize: 9),
                  ),
                  Text(
                    to,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  final String dayName;
  const _EmptyDayCard({super.key, required this.dayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded,
              color: Colors.white.withValues(alpha: .25), size: 32),
          const SizedBox(height: 8),
          Text(
            'لا يوجد أطباء يوم $dayName',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
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
                    color: color, fontSize: 12, fontWeight: FontWeight.w700),
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