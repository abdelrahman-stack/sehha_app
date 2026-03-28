// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:sehha_app/core/services/fcm_sender.dart';
// import 'package:sehha_app/core/utils/app_router.dart';
// import 'package:sehha_app/core/models/provider_service_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:url_launcher/url_launcher.dart';

// const _kAccent = Color(0xFFE91E8C);
// const _kPink2 = Color(0xFF880E4F);
// const _kPink = Color(0xFFAD1457);
// const _kDark = Color(0xFF0C0810);
// const _kDark2 = Color(0xFF160F1A);
// const _kSurf = Color(0xFF1C1020);

// class ServicesFemaleDetailsView extends StatefulWidget {
//   const ServicesFemaleDetailsView({super.key, required this.doctorModel});
//   final ProviderServiceModel doctorModel;
//   @override
//   State<ServicesFemaleDetailsView> createState() =>
//       _ServicesFemaleDetailsViewState();
// }

// class _ServicesFemaleDetailsViewState extends State<ServicesFemaleDetailsView>
//     with SingleTickerProviderStateMixin {
//   final _auth = FirebaseAuth.instance;
//   final _reqDB = FirebaseDatabase.instance.ref('Requests');
//   final _descCtrl = TextEditingController();

//   late AnimationController _btnCtrl;

//   DateTime? selectedDate;
//   int currentTurnNumber = 1;

//   @override
//   void initState() {
//     super.initState();
//     _btnCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 150),
//       lowerBound: 0,
//       upperBound: .06,
//     );
//   }

//   @override
//   void dispose() {
//     _btnCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   Stream<int> _turnStream(DateTime date) {
//     final ds = DateFormat('dd/MM/yyyy').format(date);
//     return _reqDB
//         .orderByChild('reciver')
//         .equalTo(widget.doctorModel.uid)
//         .onValue
//         .map((e) {
//           int turn = 1;
//           if (e.snapshot.value is Map) {
//             final all = <Map<String, dynamic>>[];
//             (e.snapshot.value as Map).forEach((k, v) {
//               if (v is Map) all.add(Map<String, dynamic>.from(v));
//             });
//             turn = all.where((r) => r['date'] == ds).length + 1;
//           }
//           return turn;
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final today = DateTime.now();
//     final days = List.generate(30, (i) => today.add(Duration(days: i)));

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _kDark,
//         body: Stack(
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_kDark, _kDark2, _kDark],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: [0, .5, 1],
//                 ),
//               ),
//             ),
//             const Positioned(
//               top: -60,
//               right: -50,
//               child: _Glow(200, _kPink, .07),
//             ),
//             const Positioned(
//               bottom: -40,
//               left: -40,
//               child: _Glow(160, _kAccent, .05),
//             ),

//             SafeArea(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
//                     child: Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             if (Navigator.canPop(context)) context.pop();
//                           },
//                           child: Container(
//                             width: 42,
//                             height: 42,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withValues(alpha: .06),
//                               borderRadius: BorderRadius.circular(13),
//                               border: Border.all(
//                                 color: Colors.white.withValues(alpha: .08),
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                         const Expanded(
//                           child: Text(
//                             'تفاصيل الكوافيرة',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 42),
//                       ],
//                     ),
//                   ),

//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
//                       child: Column(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: _kSurf.withValues(alpha: .75),
//                               borderRadius: BorderRadius.circular(24),
//                               border: Border.all(
//                                 color: Colors.white.withValues(alpha: .07),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withValues(alpha: .3),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 8),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.fromLTRB(
//                                     20,
//                                     24,
//                                     20,
//                                     0,
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Stack(
//                                         alignment: Alignment.center,
//                                         children: [
//                                           Container(
//                                             width: 106,
//                                             height: 106,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               gradient: LinearGradient(
//                                                 colors: [
//                                                   _kPink.withValues(alpha: .4),
//                                                   _kAccent.withValues(
//                                                     alpha: .2,
//                                                   ),
//                                                 ],
//                                               ),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: _kAccent.withValues(
//                                                     alpha: .4,
//                                                   ),
//                                                   blurRadius: 26,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 92,
//                                             height: 92,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                 color: _kAccent.withValues(
//                                                   alpha: .55,
//                                                 ),
//                                                 width: 2.5,
//                                               ),
//                                             ),
//                                             child: ClipOval(
//                                               child: Image.network(
//                                                 widget.doctorModel.profileImage,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (_, __, ___) =>
//                                                     Container(
//                                                       color: _kAccent
//                                                           .withValues(
//                                                             alpha: .1,
//                                                           ),
//                                                       child: Center(
//                                                         child: Text(
//                                                           widget
//                                                               .doctorModel
//                                                               .firstName[0],
//                                                           style:
//                                                               const TextStyle(
//                                                                 color: _kAccent,
//                                                                 fontSize: 32,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w900,
//                                                               ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 14),
//                                       Text(
//                                         widget.doctorModel.firstName,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.w900,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         widget.doctorModel.lastName,
//                                         style: TextStyle(
//                                           color: Colors.white.withValues(
//                                             alpha: .4,
//                                           ),
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 12),
//                                       // badge نشاط
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 14,
//                                           vertical: 6,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: widget.doctorModel.isActive
//                                               ? const Color(
//                                                   0xFF66BB6A,
//                                                 ).withValues(alpha: .1)
//                                               : Colors.redAccent.withValues(
//                                                   alpha: .1,
//                                                 ),
//                                           borderRadius: BorderRadius.circular(
//                                             20,
//                                           ),
//                                           border: Border.all(
//                                             color: widget.doctorModel.isActive
//                                                 ? const Color(
//                                                     0xFF66BB6A,
//                                                   ).withValues(alpha: .4)
//                                                 : Colors.redAccent.withValues(
//                                                     alpha: .4,
//                                                   ),
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Container(
//                                               width: 6,
//                                               height: 6,
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color:
//                                                     widget.doctorModel.isActive
//                                                     ? const Color(0xFF66BB6A)
//                                                     : Colors.redAccent,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 6),
//                                             Text(
//                                               widget.doctorModel.isActive
//                                                   ? 'متاحة للحجز ✓'
//                                                   : 'غير متاحة حالياً',
//                                               style: TextStyle(
//                                                 color:
//                                                     widget.doctorModel.isActive
//                                                     ? const Color(0xFF66BB6A)
//                                                     : Colors.redAccent,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(height: 16),

//                                 if (widget.doctorModel.services.isNotEmpty) ...[
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.design_services_rounded,
//                                           color: _kAccent.withValues(alpha: .6),
//                                           size: 15,
//                                         ),
//                                         const SizedBox(width: 7),
//                                         Text(
//                                           'الخدمات والأسعار',
//                                           style: TextStyle(
//                                             color: Colors.white.withValues(
//                                               alpha: .65,
//                                             ),
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Padding(
//                                     padding: const EdgeInsets.fromLTRB(
//                                       16,
//                                       0,
//                                       16,
//                                       0,
//                                     ),
//                                     child: Column(
//                                       children: widget.doctorModel.services
//                                           .map(
//                                             (s) => Container(
//                                               margin: const EdgeInsets.only(
//                                                 bottom: 8,
//                                               ),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 14,
//                                                     vertical: 10,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withValues(
//                                                   alpha: .04,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 border: Border.all(
//                                                   color: Colors.white
//                                                       .withValues(alpha: .06),
//                                                 ),
//                                               ),
//                                               child: Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       s['name'] ?? '',
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.symmetric(
//                                                           horizontal: 10,
//                                                           vertical: 4,
//                                                         ),
//                                                     decoration: BoxDecoration(
//                                                       color: _kAccent
//                                                           .withValues(
//                                                             alpha: .12,
//                                                           ),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             8,
//                                                           ),
//                                                       border: Border.all(
//                                                         color: _kAccent
//                                                             .withValues(
//                                                               alpha: .3,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                     child: Text(
//                                                       '${s['price']} ج',
//                                                       style: const TextStyle(
//                                                         color: _kAccent,
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                     ),
//                                   ),
//                                 ],

//                                 const SizedBox(height: 14),

//                                 Padding(
//                                   padding: const EdgeInsets.fromLTRB(
//                                     16,
//                                     0,
//                                     16,
//                                     0,
//                                   ),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withValues(
//                                         alpha: .04,
//                                       ),
//                                       borderRadius: BorderRadius.circular(14),
//                                       border: Border.all(
//                                         color: Colors.white.withValues(
//                                           alpha: .06,
//                                         ),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.phone_rounded,
//                                           color: _kAccent.withValues(alpha: .6),
//                                           size: 16,
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Expanded(
//                                           child: Text(
//                                             widget.doctorModel.phoneNumber,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w700,
//                                               fontSize: 15,
//                                             ),
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                             Clipboard.setData(
//                                               ClipboardData(
//                                                 text: widget
//                                                     .doctorModel
//                                                     .phoneNumber,
//                                               ),
//                                             );
//                                             _snack('تم نسخ الرقم ✓');
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(7),
//                                             decoration: BoxDecoration(
//                                               color: _kAccent.withValues(
//                                                 alpha: .1,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: const Icon(
//                                               Icons.copy_rounded,
//                                               color: _kAccent,
//                                               size: 15,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 12),

//                                 // العنوان
//                                 Padding(
//                                   padding: const EdgeInsets.fromLTRB(
//                                     16,
//                                     0,
//                                     16,
//                                     0,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.location_on_rounded,
//                                         color: Colors.redAccent.withValues(
//                                           alpha: .7,
//                                         ),
//                                         size: 14,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           widget.doctorModel.address,
//                                           style: TextStyle(
//                                             color: Colors.white.withValues(
//                                               alpha: .45,
//                                             ),
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(height: 14),

//                                 Padding(
//                                   padding: const EdgeInsets.fromLTRB(
//                                     16,
//                                     0,
//                                     16,
//                                     20,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       _CircleBtn(
//                                         icon: Icons.call_rounded,
//                                         color: const Color(0xFF66BB6A),
//                                         label: 'اتصال',
//                                         onTap: () async {
//                                           final u = Uri(
//                                             scheme: 'tel',
//                                             path: widget.doctorModel.phoneNumber
//                                                 .replaceAll(
//                                                   RegExp(r'[\s-]'),
//                                                   '',
//                                                 ),
//                                           );
//                                           if (await canLaunchUrl(u)) {
//                                             await launchUrl(
//                                               u,
//                                               mode: LaunchMode
//                                                   .externalApplication,
//                                             );
//                                           }
//                                         },
//                                       ),
//                                       const SizedBox(width: 14),
//                                       _CircleBtn(
//                                         icon: Icons.chat_bubble_rounded,
//                                         color: const Color(0xFF42A5F5),
//                                         label: 'رسالة',
//                                         onTap: () {
//                                           final uid = _auth.currentUser!.uid;
//                                           final other = widget.doctorModel.uid;
//                                           final chatId =
//                                               uid.compareTo(other) < 0
//                                               ? '$uid-$other'
//                                               : '$other-$uid';
//                                           GoRouter.of(context).push(
//                                             AppRouter.kChatView,
//                                             extra: {
//                                               'myId': uid,
//                                               'otherUserId': other,
//                                               'otherUserName':
//                                                   widget.doctorModel.firstName,
//                                               'chatId': chatId,
//                                               'isFemaleChat': true,
//                                             },
//                                           );
//                                         },
//                                       ),
//                                       const SizedBox(width: 14),
//                                       _CircleBtn(
//                                         icon: Icons.map_outlined,
//                                         color: _kAccent,
//                                         label: 'الخريطة',
//                                         onTap: () async {
//                                           final lat =
//                                               widget.doctorModel.latitude;
//                                           final lng =
//                                               widget.doctorModel.longitude;
//                                           if (lat == 0 || lng == 0) return;
//                                           final u = Uri.parse(
//                                             'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//                                           );
//                                           if (await canLaunchUrl(u)) {
//                                             await launchUrl(
//                                               u,
//                                               mode: LaunchMode
//                                                   .externalApplication,
//                                             );
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(height: 18),

//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Text(
//                               'اختاري يوم الحجز',
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: .7),
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),

//                           SizedBox(
//                             height: 94,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: days.length,
//                               itemBuilder: (_, i) {
//                                 final day = days[i];
//                                 final isSel =
//                                     selectedDate != null &&
//                                     day.year == selectedDate!.year &&
//                                     day.month == selectedDate!.month &&
//                                     day.day == selectedDate!.day;
//                                 final isToday =
//                                     day.year == today.year &&
//                                     day.month == today.month &&
//                                     day.day == today.day;

//                                 return StreamBuilder<int>(
//                                   stream: _turnStream(day),
//                                   builder: (_, snap) {
//                                     final turn = snap.data ?? 1;
//                                     return GestureDetector(
//                                       onTap: () => setState(() {
//                                         if (isSel) {
//                                           selectedDate = null;
//                                           currentTurnNumber = 1;
//                                         } else {
//                                           selectedDate = day;
//                                           currentTurnNumber = turn;
//                                         }
//                                       }),
//                                       child: AnimatedContainer(
//                                         duration: const Duration(
//                                           milliseconds: 220,
//                                         ),
//                                         margin: const EdgeInsets.only(
//                                           right: 10,
//                                         ),
//                                         width: 74,
//                                         decoration: BoxDecoration(
//                                           gradient: isSel
//                                               ? const LinearGradient(
//                                                   colors: [_kAccent, _kPink2],
//                                                   begin: Alignment.topLeft,
//                                                   end: Alignment.bottomRight,
//                                                 )
//                                               : null,
//                                           color: isSel
//                                               ? null
//                                               : isToday
//                                               ? _kAccent.withValues(alpha: .08)
//                                               : Colors.white.withValues(
//                                                   alpha: .06,
//                                                 ),
//                                           borderRadius: BorderRadius.circular(
//                                             16,
//                                           ),
//                                           border: Border.all(
//                                             color: isSel
//                                                 ? Colors.transparent
//                                                 : isToday
//                                                 ? _kAccent.withValues(alpha: .4)
//                                                 : Colors.white.withValues(
//                                                     alpha: .08,
//                                                   ),
//                                           ),
//                                           boxShadow: isSel
//                                               ? [
//                                                   BoxShadow(
//                                                     color: _kAccent.withValues(
//                                                       alpha: .45,
//                                                     ),
//                                                     blurRadius: 14,
//                                                     offset: const Offset(0, 4),
//                                                   ),
//                                                 ]
//                                               : [],
//                                         ),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               DateFormat(
//                                                 'EEE',
//                                                 'ar',
//                                               ).format(day),
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 color: isSel
//                                                     ? Colors.white
//                                                     : Colors.white.withValues(
//                                                         alpha: .45,
//                                                       ),
//                                                 fontWeight: FontWeight.w700,
//                                                 fontSize: 10,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               DateFormat('dd/MM').format(day),
//                                               style: TextStyle(
//                                                 color: isSel
//                                                     ? Colors.white
//                                                     : Colors.white.withValues(
//                                                         alpha: .72,
//                                                       ),
//                                                 fontWeight: FontWeight.w700,
//                                                 fontSize: 13,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 6,
//                                                     vertical: 2,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: isSel
//                                                     ? Colors.white.withValues(
//                                                         alpha: .2,
//                                                       )
//                                                     : _kAccent.withValues(
//                                                         alpha: .12,
//                                                       ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: Text(
//                                                 '$turn',
//                                                 style: TextStyle(
//                                                   color: isSel
//                                                       ? Colors.white
//                                                       : _kAccent,
//                                                   fontSize: 11,
//                                                   fontWeight: FontWeight.w800,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           if (selectedDate != null)
//                             StreamBuilder<int>(
//                               stream: _turnStream(selectedDate!),
//                               builder: (_, snap) {
//                                 final t = snap.data ?? currentTurnNumber;
//                                 if (snap.hasData) {
//                                   WidgetsBinding.instance.addPostFrameCallback((
//                                     _,
//                                   ) {
//                                     if (mounted) {
//                                       setState(() => currentTurnNumber = t);
//                                     }
//                                   });
//                                 }
//                                 return AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: _kAccent.withValues(alpha: .08),
//                                     borderRadius: BorderRadius.circular(16),
//                                     border: Border.all(
//                                       color: _kAccent.withValues(alpha: .25),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.format_list_numbered_rounded,
//                                         color: _kAccent.withValues(alpha: .7),
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'سيكون دورك رقم ',
//                                         style: TextStyle(
//                                           color: Colors.white.withValues(
//                                             alpha: .5,
//                                           ),
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                       Text(
//                                         '$t',
//                                         style: const TextStyle(
//                                           color: _kAccent,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w900,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),

//                           Container(
//                             decoration: BoxDecoration(
//                               color: _kSurf.withValues(alpha: .6),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: Colors.white.withValues(alpha: .06),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: _descCtrl,
//                               maxLines: 3,
//                               minLines: 2,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                               cursorColor: _kAccent,
//                               decoration: InputDecoration(
//                                 hintText: 'أضيفي تفاصيل الحجز (اختياري)...',
//                                 hintStyle: TextStyle(
//                                   color: Colors.white.withValues(alpha: .2),
//                                   fontSize: 13,
//                                 ),
//                                 contentPadding: const EdgeInsets.all(14),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 16),

//                           GestureDetector(
//                             onTapDown: (_) => _btnCtrl.forward(),
//                             onTapUp: (_) {
//                               _btnCtrl.reverse();
//                               _makeAppointment();
//                             },
//                             onTapCancel: () => _btnCtrl.reverse(),
//                             child: AnimatedBuilder(
//                               animation: _btnCtrl,
//                               builder: (_, __) => Transform.scale(
//                                 scale: 1 - _btnCtrl.value,
//                                 child: Container(
//                                   height: 56,
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     gradient: widget.doctorModel.isActive
//                                         ? const LinearGradient(
//                                             colors: [_kAccent, _kPink2],
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                           )
//                                         : null,
//                                     color: widget.doctorModel.isActive
//                                         ? null
//                                         : Colors.white.withValues(alpha: .06),
//                                     borderRadius: BorderRadius.circular(18),
//                                     boxShadow: widget.doctorModel.isActive
//                                         ? [
//                                             BoxShadow(
//                                               color: _kAccent.withValues(
//                                                 alpha: .5,
//                                               ),
//                                               blurRadius: 20,
//                                               offset: const Offset(0, 6),
//                                             ),
//                                           ]
//                                         : [],
//                                   ),
//                                   child: Center(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           widget.doctorModel.isActive
//                                               ? Icons.bookmark_add_rounded
//                                               : Icons.block_rounded,
//                                           color: widget.doctorModel.isActive
//                                               ? Colors.white
//                                               : Colors.white.withValues(
//                                                   alpha: .25,
//                                                 ),
//                                           size: 20,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           widget.doctorModel.isActive
//                                               ? 'احجزي الآن ✨'
//                                               : 'الكوافيرة غير متاحة',
//                                           style: TextStyle(
//                                             color: widget.doctorModel.isActive
//                                                 ? Colors.white
//                                                 : Colors.white.withValues(
//                                                     alpha: .28,
//                                                   ),
//                                             fontWeight: FontWeight.w800,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _makeAppointment() async {
//     if (!widget.doctorModel.isActive) {
//       _snack('الكوافيرة غير متاحة حالياً', err: true);
//       return;
//     }
//     if (selectedDate == null) {
//       _snack('اختاري يوم الحجز أولاً', err: true);
//       return;
//     }

//     final uid = _auth.currentUser!.uid;
//     final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
//     final reqId = _reqDB.push().key!;
//     final desc = _descCtrl.text.trim();

//     // جلب بيانات العميلة من ClientFemales
//     final patSnap = await FirebaseDatabase.instance
//         .ref('ClientFemales/$uid')
//         .get();
//     String name = 'غير معروف', img = '', phone = '';
//     if (patSnap.exists) {
//       final d = Map<String, dynamic>.from(patSnap.value as Map);
//       name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
//       img = d['profileImage'] ?? '';
//       phone = d['phoneNumber'] ?? '';
//     }

//     await _reqDB.child(reqId).set({
//       'date': dateStr,
//       'description': desc.isEmpty ? null : desc,
//       'id': reqId,
//       'sender': uid,
//       'senderPhone': phone,
//       'senderName': name,
//       'senderImage': img,
//       'reciver': widget.doctorModel.uid,
//       'status': 'انتظار الرد',
//       'turnNumber': currentTurnNumber,
//       'ratingStatus': 'انتظار التقييم',
//       'rating': null,
//     });

//     final tokSnap = await FirebaseDatabase.instance
//         .ref('Hairdressers/${widget.doctorModel.uid}/fcmToken')
//         .get();
//     if (tokSnap.exists) {
//       await FcmSender.send(
//         token: tokSnap.value.toString(),
//         title: 'حجز جديد 💅',
//         body: 'عميلة جديدة حجزت – دورها رقم $currentTurnNumber',
//       );
//     }

//     setState(() {
//       selectedDate = null;
//       _descCtrl.clear();
//       currentTurnNumber = 1;
//     });
//     _snack('تم إرسال الحجز بنجاح 🎉');
//     HapticFeedback.mediumImpact();
//   }

//   void _snack(String msg, {bool err = false}) =>
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           backgroundColor: err ? Colors.redAccent : _kAccent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
// }

// class _CircleBtn extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final VoidCallback onTap;
//   const _CircleBtn({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 52,
//           height: 52,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color.withValues(alpha: .1),
//             border: Border.all(color: color.withValues(alpha: .3)),
//             boxShadow: [
//               BoxShadow(color: color.withValues(alpha: .2), blurRadius: 12),
//             ],
//           ),
//           child: Icon(icon, color: color, size: 22),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           label,
//           style: TextStyle(
//             color: color,
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _Glow extends StatelessWidget {
//   final double size;
//   final Color color;
//   final double opacity;
//   const _Glow(this.size, this.color, this.opacity);
//   @override
//   Widget build(BuildContext context) => Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: color.withValues(alpha: opacity),
//     ),
//   );
// }

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

const _kAccent = Color(0xFFE91E8C);
const _kPink2 = Color(0xFF880E4F);
const _kPink = Color(0xFFAD1457);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);

class ServicesFemaleDetailsView extends StatefulWidget {
  const ServicesFemaleDetailsView({super.key, required this.doctorModel});
  final ProviderServiceModel doctorModel;
  @override
  State<ServicesFemaleDetailsView> createState() =>
      _ServicesFemaleDetailsViewState();
}

class _ServicesFemaleDetailsViewState extends State<ServicesFemaleDetailsView>
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
        .ref('Users/Hairdressers/${widget.doctorModel.uid}/isActive')
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
        .ref('Hairdressers/$barberId/dailyTurn/$dateKey')
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
    final hairdresserId = widget.doctorModel.uid;
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final snap = await database
        .orderByChild('reciver')
        .equalTo(hairdresserId)
        .get();
    int count = 0;
    if (snap.exists && snap.value != null) {
      (snap.value as Map).forEach((k, v) {
        if (v is Map && v['date'] == dateStr) count++;
      });
    }
    final dSnap = await FirebaseDatabase.instance
        .ref('Hairdressers/$hairdresserId/dailyTurn/$dateKey')
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
                backgroundColor: _kPink,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {}
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
                    t.translate('تفاصيل الكوافيرة'),
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
                                      'الكوافير غير متاح حاليًا',
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
                                  color: _kPink,
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
                              color: _kPink,
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
                                  color: _kAccent.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  color: _kPink,
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
                                          ? _kAccent
                                          : (isToday
                                                ? _kAccent.withValues(alpha: .2)
                                                : Colors.white.withValues(
                                                    alpha: .07,
                                                  )),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSel
                                            ? _kAccent.withValues(alpha: .8)
                                            : (isToday
                                                  ? _kAccent.withValues(
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
                                                        ? _kPink
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
                              color: _kPink2.withValues(alpha: .7),
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
    final patSnap = await FirebaseDatabase.instance
        .ref('ClientFemales/$uid')
        .get();
    String uName = 'غير معروف', uImage = '', uPhone = '';
    if (patSnap.exists) {
      final d = Map<String, dynamic>.from(patSnap.value as Map);
      uName = '${d['firstName']} ${d['lastName']}';
      uImage = d['profileImage'] ?? '';
      uPhone = d['phoneNumber'] ?? '';
    }
    final reciverId = widget.doctorModel.uid;
    if (!widget.doctorModel.isActive) {
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
              .ref('Hairdressers/$reciverId/fcmToken')
              .get();
          final token = bSnap.value as String?;
          if (token != null && token.isNotEmpty) {
            await FcmSender.send(
              token: token,
              title: 'حجز جديد 💅',
              body: 'عميلة جديدة حجزت – دورها رقم $currentTurnNumber',
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
