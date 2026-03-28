// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../widgets/lottie_loading_Indicator.dart';
// import '../../core/utils/app_router.dart';
// import '../../core/models/provider_service_model.dart';

// class BeautyCenterProfileView extends StatefulWidget {
//   const BeautyCenterProfileView({super.key});
//   @override
//   State<BeautyCenterProfileView> createState() =>
//       _BeautyCenterProfileViewState();
// }

// class _BeautyCenterProfileViewState extends State<BeautyCenterProfileView>
//     with SingleTickerProviderStateMixin {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final DatabaseReference beautyCenterDB = FirebaseDatabase.instance.ref(
//     'BeautyCenter',
//   );
//   StreamSubscription<DatabaseEvent>? beautyCenterSub;

//   bool isUpdatingActive = false;
//   ProviderServiceModel? beautyCenter;
//   bool isLoading = true;
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController firstNameController;
//   late TextEditingController lastNameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;
//   File? pickedImage;

//   late AnimationController _fadeCtrl;
//   late Animation<double> _fadeAnim;

//   static const _blue = Color(0xFFEDD49A);
//   static const _blue2 = Color(0xFF1A8A84);
//   static const _kDark = Color(0xFF0C0810);
//   static const _kAccent = Color(0xFF7EDBD5);
//   static const _kDark2 = Color(0xFF160F1A);

//   @override
//   void initState() {
//     super.initState();
//     firstNameController = TextEditingController();
//     lastNameController = TextEditingController();
//     emailController = TextEditingController();
//     phoneController = TextEditingController();
//     addressController = TextEditingController();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _listenToBarber();
//   }

//   @override
//   void dispose() {
//     beautyCenterSub?.cancel();
//     _fadeCtrl.dispose();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   void _listenToBarber() {
//     final uid = auth.currentUser?.uid;
//     if (uid == null) return;
//     beautyCenterSub = beautyCenterDB.child(uid).onValue.listen((event) {
//       if (event.snapshot.exists && mounted) {
//         final data = Map<String, dynamic>.from(event.snapshot.value as Map);
//         setState(() {
//           beautyCenter = ProviderServiceModel.fromMap(data);
//           firstNameController.text = beautyCenter!.firstName;
//           lastNameController.text = beautyCenter!.lastName;
//           emailController.text = beautyCenter!.email;
//           phoneController.text = beautyCenter!.phoneNumber;
//           addressController.text = beautyCenter!.address;
//           isLoading = false;
//         });
//         _fadeCtrl.forward(from: 0);
//       }
//     });
//   }

//   Future<void> pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) setState(() => pickedImage = File(picked.path));
//   }

//   Future<void> updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => isLoading = true);
//     try {
//       await beautyCenterDB.child(auth.currentUser!.uid).update({
//         'firstName': firstNameController.text.trim(),
//         'lastName': lastNameController.text.trim(),
//         'email': emailController.text.trim(),
//         'phoneNumber': phoneController.text.trim(),
//         'address': addressController.text.trim(),
//       });
//       if (!mounted) return;
//       Navigator.pop(context);
//       _showSnack('تم تحديث الملف الشخصي بنجاح', Colors.green);
//     } catch (_) {
//       _showSnack('حدث خطأ أثناء التحديث', Colors.redAccent);
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   Future<void> updateLocation() async {
//     try {
//       bool enabled = await Geolocator.isLocationServiceEnabled();
//       if (!enabled) {
//         _showSnack('فعّل خدمة الموقع أولاً', Colors.redAccent);
//         return;
//       }
//       LocationPermission p = await Geolocator.checkPermission();
//       if (p == LocationPermission.denied) {
//         p = await Geolocator.requestPermission();
//         if (p == LocationPermission.denied) return;
//       }
//       if (p == LocationPermission.deniedForever) return;
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       await beautyCenterDB.child(beautyCenter!.uid).update({
//         'latitude': pos.latitude,
//         'longitude': pos.longitude,
//       });
//       setState(
//         () => beautyCenter = beautyCenter!.copyWith(
//           latitude: pos.latitude,
//           longitude: pos.longitude,
//         ),
//       );
//       _showSnack('تم تحديث الموقع بنجاح', Colors.green);
//     } catch (e) {
//       _showSnack('فشل تحديث الموقع: $e', Colors.redAccent);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
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
//           const Positioned(
//             top: -50,
//             right: -50,
//             child: _Glow(size: 200, color: _kAccent),
//           ),
//           const Positioned(
//             bottom: -80,
//             left: -50,
//             child: _Glow(size: 180, color: _kAccent),
//           ),

//           SafeArea(
//             child: isLoading
//                 ? const Center(child: CustomCircularProgressIndicator())
//                 : beautyCenter == null
//                 ? const Center(
//                     child: Text(
//                       'لا توجد بيانات',
//                       style: TextStyle(color: Colors.white54),
//                     ),
//                   )
//                 : FadeTransition(
//                     opacity: _fadeAnim,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           _buildHeader(),
//                           const SizedBox(height: 24),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Column(
//                               children: [
//                                 _InfoCard(
//                                   children: [
//                                     _InfoRow(
//                                       icon: Icons.email_outlined,
//                                       label: 'البريد',
//                                       value: beautyCenter!.email,
//                                       color: _blue2,
//                                     ),
//                                     _Divider(),
//                                     _InfoRow(
//                                       icon: Icons.phone_outlined,
//                                       label: 'الهاتف',
//                                       value: beautyCenter!.phoneNumber,
//                                       color: _blue2,
//                                     ),
//                                     _Divider(),
//                                     _InfoRow(
//                                       icon: Icons.location_on_outlined,
//                                       label: 'العنوان',
//                                       value: beautyCenter!.address,
//                                       color: _blue2,
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 14),

//                                 _ActionBtn(
//                                   icon: Icons.my_location_rounded,
//                                   label: 'تحديث الموقع الحالي',
//                                   color: _blue,
//                                   onTap: updateLocation,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 _ActionBtn(
//                                   icon: Icons.edit_rounded,
//                                   label: 'تعديل الملف الشخصي',
//                                   color: _blue2,
//                                   onTap: () => showDialog(
//                                     context: context,
//                                     builder: (_) => _editProfileDialog(),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 _ActionBtn(
//                                   icon: Icons.design_services_rounded,
//                                   label: 'تعديل الخدمات والأسعار',
//                                   color: _blue2,
//                                   onTap: () => showDialog(
//                                     context: context,
//                                     builder: (_) => _editServicesDialog(),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 _ActionBtn(
//                                   icon: Icons.logout_rounded,
//                                   label: 'تسجيل الخروج',
//                                   color: Colors.redAccent,
//                                   onTap: _confirmLogout,
//                                 ),

//                                 const SizedBox(height: 32),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             _kDark2.withValues(alpha: .5),
//             _kAccent.withValues(alpha: .3),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withValues(alpha: .06)),
//         ),
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: _blue2.withValues(alpha: .6),
//                     width: 2.5,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _blue.withValues(alpha: .4),
//                       blurRadius: 20,
//                     ),
//                   ],
//                 ),
//                 child: ClipOval(
//                   child: pickedImage != null
//                       ? Image.file(pickedImage!, fit: BoxFit.cover)
//                       : beautyCenter!.profileImage.isNotEmpty
//                       ? Image.network(
//                           beautyCenter!.profileImage,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           color: Colors.white12,
//                           child: const Icon(
//                             Icons.person_rounded,
//                             size: 46,
//                             color: Colors.white38,
//                           ),
//                         ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 2,
//                 right: 2,
//                 child: GestureDetector(
//                   onTap: pickImage,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: _blue2,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFF0D1B2A),
//                         width: 2,
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.camera_alt_rounded,
//                       size: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Text(
//             beautyCenter!.firstName,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             beautyCenter!.lastName,
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: .5),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 24),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: .06),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.white.withValues(alpha: .08)),
//             ),
//             child: Row(
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: beautyCenter!.isActive
//                         ? Colors.greenAccent
//                         : Colors.redAccent,
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             (beautyCenter!.isActive
//                                     ? Colors.greenAccent
//                                     : Colors.redAccent)
//                                 .withValues(alpha: .6),
//                         blurRadius: 8,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'استقبال العملاء',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         beautyCenter!.isActive
//                             ? 'متاح للحجوزات'
//                             : 'غير متاح حالياً',
//                         style: TextStyle(
//                           color: beautyCenter!.isActive
//                               ? Colors.greenAccent
//                               : Colors.redAccent,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Switch.adaptive(
//                   value: beautyCenter!.isActive,
//                   onChanged: isUpdatingActive
//                       ? null
//                       : (val) async {
//                           setState(() => isUpdatingActive = true);
//                           await beautyCenterDB.child(beautyCenter!.uid).update({
//                             'isActive': val,
//                           });
//                           setState(() {
//                             beautyCenter = beautyCenter!.copyWith(
//                               isActive: val,
//                             );
//                             isUpdatingActive = false;
//                           });
//                         },
//                   activeColor: Colors.greenAccent,
//                   inactiveThumbColor: Colors.white54,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _editProfileDialog() => Dialog(
//     backgroundColor: _kDark2,
//     shape: RoundedRectangleBorder(
//       side: BorderSide(color: Colors.white.withValues(alpha: .15)),
//       borderRadius: BorderRadius.circular(24),
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: _blue.withValues(alpha: .2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.edit_rounded,
//                     color: _blue2,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'تعديل الملف الشخصي',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   _DarkField(
//                     ctrl: firstNameController,
//                     label: 'الاسم الأول',
//                     icon: Icons.person_outline_rounded,
//                     accent: _blue2,
//                   ),
//                   const SizedBox(height: 10),
//                   _DarkField(
//                     ctrl: lastNameController,
//                     label: 'اسم العائلة',
//                     icon: Icons.person_outline_rounded,
//                     accent: _blue2,
//                   ),
//                   const SizedBox(height: 10),
//                   _DarkField(
//                     ctrl: emailController,
//                     label: 'البريد الإلكتروني',
//                     icon: Icons.email_outlined,
//                     accent: _blue2,
//                     keyboard: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 10),
//                   _DarkField(
//                     ctrl: phoneController,
//                     label: 'رقم الهاتف',
//                     icon: Icons.phone_outlined,
//                     accent: _blue2,
//                     keyboard: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 10),
//                   _DarkField(
//                     ctrl: addressController,
//                     label: 'العنوان',
//                     icon: Icons.location_on_outlined,
//                     accent: _blue2,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       height: 48,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Colors.white.withValues(alpha: .15),
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'إلغاء',
//                           style: TextStyle(
//                             color: Colors.white.withValues(alpha: .5),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: updateProfile,
//                     child: Container(
//                       height: 48,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         gradient: const LinearGradient(colors: [_blue, _blue2]),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _blue.withValues(alpha: .4),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'حفظ',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//   Widget _editServicesDialog() {
//     List<Map<String, dynamic>> editableServices = beautyCenter!.services
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();
//     return StatefulBuilder(
//       builder: (context, setS) => Dialog(
//         backgroundColor: _kDark,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: Colors.white.withValues(alpha: .15)),
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: _blue.withValues(alpha: .2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.design_services_rounded,
//                         color: _blue2,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'تعديل الخدمات',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 ...List.generate(
//                   editableServices.length,
//                   (i) => Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _DarkFieldRaw(
//                             init: editableServices[i]['name'],
//                             label: 'اسم الخدمة',
//                             accent: _blue2,
//                             onChanged: (v) => editableServices[i]['name'] = v,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           width: 90,
//                           child: _DarkFieldRaw(
//                             init: editableServices[i]['price'],
//                             label: 'السعر',
//                             accent: _blue2,
//                             keyboard: TextInputType.number,
//                             onChanged: (v) => editableServices[i]['price'] = v,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         GestureDetector(
//                           onTap: () => setS(() => editableServices.removeAt(i)),
//                           child: Container(
//                             width: 36,
//                             height: 36,
//                             decoration: BoxDecoration(
//                               color: Colors.red.withValues(alpha: .12),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(
//                               Icons.delete_outline_rounded,
//                               color: Colors.redAccent,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 GestureDetector(
//                   onTap: () => setS(
//                     () => editableServices.add({'name': '', 'price': ''}),
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: _blue2.withValues(alpha: .4),
//                         width: 1.5,
//                       ),
//                       color: Colors.white.withValues(alpha: .04),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add_rounded, color: _blue2, size: 18),
//                         SizedBox(width: 6),
//                         Text(
//                           'إضافة خدمة',
//                           style: TextStyle(
//                             color: _blue2,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     await beautyCenterDB.child(beautyCenter!.uid).update({
//                       'services': editableServices,
//                     });
//                     if (context.mounted) Navigator.pop(context);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       gradient: const LinearGradient(colors: [_blue, _blue2]),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _blue.withValues(alpha: .4),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'حفظ التعديلات',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _confirmLogout() async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: _kDark2,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: Colors.white.withValues(alpha: .15)),
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.red.withValues(alpha: .12),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.logout_rounded,
//                   color: Colors.redAccent,
//                   size: 28,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               const Text(
//                 'تسجيل الخروج',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'هل تريد تسجيل الخروج؟',
//                 style: TextStyle(
//                   color: Colors.white.withValues(alpha: .55),
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context, false),
//                       child: Container(
//                         height: 46,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Colors.white.withValues(alpha: .12),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'إلغاء',
//                             style: TextStyle(
//                               color: Colors.white.withValues(alpha: .5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context, true),
//                       child: Container(
//                         height: 46,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: Colors.redAccent,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.redAccent.withValues(alpha: .4),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'تسجيل الخروج',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//     if (ok == true) {
//       await auth.signOut();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.clear();
//       if (mounted) {
//         GoRouter.of(context).pushReplacement(AppRouter.kServicesSelectionView);
//       }
//     }
//   }
// }

// // ─── Shared Widgets ───
// class _InfoCard extends StatelessWidget {
//   final List<Widget> children;
//   const _InfoCard({required this.children});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//     decoration: BoxDecoration(
//       color: Colors.white.withValues(alpha: .06),
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: Colors.white.withValues(alpha: .08)),
//     ),
//     child: Column(children: children),
//   );
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label, value;
//   final Color color;
//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 12),
//     child: Row(
//       children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 12),
//         Text(
//           '$label:  ',
//           style: const TextStyle(color: Colors.white60, fontSize: 13),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _Divider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) =>
//       Divider(color: Colors.white.withValues(alpha: .07), height: 1);
// }

// class _ActionBtn extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ActionBtn({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//   @override
//   State<_ActionBtn> createState() => _ActionBtnState();
// }

// class _ActionBtnState extends State<_ActionBtn>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _c;
//   late Animation<double> _s;
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//     );
//     _s = Tween<double>(
//       begin: 1.0,
//       end: 0.97,
//     ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTapDown: (_) => _c.forward(),
//     onTapUp: (_) {
//       _c.reverse();
//       widget.onTap();
//     },
//     onTapCancel: () => _c.reverse(),
//     child: ScaleTransition(
//       scale: _s,
//       child: Container(
//         height: 52,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: widget.color.withValues(alpha: .12),
//           border: Border.all(
//             color: widget.color.withValues(alpha: .3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(widget.icon, color: widget.color, size: 18),
//             const SizedBox(width: 10),
//             Text(
//               widget.label,
//               style: TextStyle(
//                 color: widget.color,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// class _DarkField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label;
//   final IconData icon;
//   final Color accent;
//   final TextInputType keyboard;
//   const _DarkField({
//     required this.ctrl,
//     required this.label,
//     required this.icon,
//     required this.accent,
//     this.keyboard = TextInputType.text,
//   });
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     controller: ctrl,
//     keyboardType: keyboard,
//     style: const TextStyle(color: Colors.white, fontSize: 14),
//     validator: (v) => v!.isEmpty ? 'مطلوب' : null,
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(
//         color: Colors.white.withValues(alpha: .45),
//         fontSize: 13,
//       ),
//       prefixIcon: Icon(icon, color: Colors.white38, size: 18),
//       filled: true,
//       fillColor: Colors.white.withValues(alpha: .07),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: accent.withValues(alpha: .7), width: 1.5),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.redAccent),
//       ),
//     ),
//   );
// }

// class _DarkFieldRaw extends StatelessWidget {
//   final String? init;
//   final String label;
//   final Color accent;
//   final TextInputType keyboard;
//   final Function(String) onChanged;
//   const _DarkFieldRaw({
//     this.init,
//     required this.label,
//     required this.accent,
//     this.keyboard = TextInputType.text,
//     required this.onChanged,
//   });
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     initialValue: init,
//     keyboardType: keyboard,
//     onChanged: onChanged,
//     style: const TextStyle(color: Colors.white, fontSize: 13),
//     decoration: InputDecoration(
//       labelText: label,
//       isDense: true,
//       labelStyle: TextStyle(
//         color: Colors.white.withValues(alpha: .4),
//         fontSize: 12,
//       ),
//       filled: true,
//       fillColor: Colors.white.withValues(alpha: .07),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: accent.withValues(alpha: .7), width: 1.5),
//       ),
//     ),
//   );
// }

// class _Glow extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Glow({required this.size, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: color.withValues(alpha: .12),
//     ),
//   );
// }





import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/lottie_loading_Indicator.dart';
import '../../core/utils/app_router.dart';
import '../../core/models/provider_service_model.dart';

class BeautyCenterProfileView extends StatefulWidget {
  const BeautyCenterProfileView({super.key});
  @override
  State<BeautyCenterProfileView> createState() =>
      _BeautyCenterProfileViewState();
}

class _BeautyCenterProfileViewState extends State<BeautyCenterProfileView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference beautyCenterDB =
      FirebaseDatabase.instance.ref('BeautyCenter');
  StreamSubscription<DatabaseEvent>? beautyCenterSub;

  bool isUpdatingActive = false;
  ProviderServiceModel? beautyCenter;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? pickedImage;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _blue = Color(0xFFEDD49A);
  static const _blue2 = Color(0xFF1A8A84);
  static const _kDark = Color(0xFF0C0810);
  static const _kAccent = Color(0xFF7EDBD5);
  static const _kDark2 = Color(0xFF160F1A);

  // ── day names ──
  static const _kDayNames = {
    1: 'الاثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _listenToBarber();
  }

  @override
  void dispose() {
    beautyCenterSub?.cancel();
    _fadeCtrl.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _listenToBarber() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    beautyCenterSub = beautyCenterDB.child(uid).onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          beautyCenter = ProviderServiceModel.fromMap(data);
          firstNameController.text = beautyCenter!.firstName;
          lastNameController.text = beautyCenter!.lastName;
          emailController.text = beautyCenter!.email;
          phoneController.text = beautyCenter!.phoneNumber;
          addressController.text = beautyCenter!.address;
          isLoading = false;
        });
        _fadeCtrl.forward(from: 0);
      }
    });
  }

  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pickedImage = File(picked.path));
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await beautyCenterDB.child(auth.currentUser!.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'address': addressController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('تم تحديث الملف الشخصي بنجاح', Colors.green);
    } catch (_) {
      _showSnack('حدث خطأ أثناء التحديث', Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showSnack('فعّل خدمة الموقع أولاً', Colors.redAccent);
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
        if (p == LocationPermission.denied) return;
      }
      if (p == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await beautyCenterDB.child(beautyCenter!.uid).update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
      setState(() => beautyCenter = beautyCenter!.copyWith(
            latitude: pos.latitude,
            longitude: pos.longitude,
          ));
      _showSnack('تم تحديث الموقع بنجاح', Colors.green);
    } catch (e) {
      _showSnack('فشل تحديث الموقع: $e', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
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

  @override
  Widget build(BuildContext context) {
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
          const Positioned(
              top: -50,
              right: -50,
              child: _Glow(size: 200, color: _kAccent)),
          const Positioned(
              bottom: -80,
              left: -50,
              child: _Glow(size: 180, color: _kAccent)),

          SafeArea(
            child: isLoading
                ? const Center(child: CustomCircularProgressIndicator())
                : beautyCenter == null
                    ? const Center(
                        child: Text('لا توجد بيانات',
                            style: TextStyle(color: Colors.white54)))
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Column(
                                  children: [
                                    _InfoCard(
                                      children: [
                                        _InfoRow(
                                          icon: Icons.email_outlined,
                                          label: 'البريد',
                                          value: beautyCenter!.email,
                                          color: _blue2,
                                        ),
                                        _Divider(),
                                        _InfoRow(
                                          icon: Icons.phone_outlined,
                                          label: 'الهاتف',
                                          value: beautyCenter!.phoneNumber,
                                          color: _blue2,
                                        ),
                                        _Divider(),
                                        _InfoRow(
                                          icon: Icons.location_on_outlined,
                                          label: 'العنوان',
                                          value: beautyCenter!.address,
                                          color: _blue2,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    _ActionBtn(
                                      icon: Icons.my_location_rounded,
                                      label: 'تحديث الموقع الحالي',
                                      color: _blue,
                                      onTap: updateLocation,
                                    ),
                                    const SizedBox(height: 10),
                                    _ActionBtn(
                                      icon: Icons.edit_rounded,
                                      label: 'تعديل الملف الشخصي',
                                      color: _blue2,
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => _editProfileDialog(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _ActionBtn(
                                      icon: Icons.design_services_rounded,
                                      label: 'تعديل الخدمات والأسعار',
                                      color: _blue2,
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => _editServicesDialog(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // ── NEW: Doctors button ──────────────
                                    _ActionBtn(
                                      icon: Icons.medical_services_rounded,
                                      label: 'إدارة الأطباء والمختصين',
                                      color: _kAccent,
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => _editDoctorsDialog(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    _ActionBtn(
                                      icon: Icons.logout_rounded,
                                      label: 'تسجيل الخروج',
                                      color: Colors.redAccent,
                                      onTap: _confirmLogout,
                                    ),

                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kDark2.withValues(alpha: .5),
            _kAccent.withValues(alpha: .3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: .06))),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: _blue2.withValues(alpha: .6), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                        color: _blue.withValues(alpha: .4), blurRadius: 20)
                  ],
                ),
                child: ClipOval(
                  child: pickedImage != null
                      ? Image.file(pickedImage!, fit: BoxFit.cover)
                      : beautyCenter!.profileImage.isNotEmpty
                          ? Image.network(beautyCenter!.profileImage,
                              fit: BoxFit.cover)
                          : Container(
                              color: Colors.white12,
                              child: const Icon(Icons.person_rounded,
                                  size: 46, color: Colors.white38),
                            ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _blue2,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF0D1B2A), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            beautyCenter!.firstName,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            beautyCenter!.lastName,
            style: TextStyle(
                color: Colors.white.withValues(alpha: .5), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: beautyCenter!.isActive
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    boxShadow: [
                      BoxShadow(
                        color: (beautyCenter!.isActive
                                ? Colors.greenAccent
                                : Colors.redAccent)
                            .withValues(alpha: .6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('استقبال العملاء',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text(
                        beautyCenter!.isActive
                            ? 'متاح للحجوزات'
                            : 'غير متاح حالياً',
                        style: TextStyle(
                          color: beautyCenter!.isActive
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: beautyCenter!.isActive,
                  onChanged: isUpdatingActive
                      ? null
                      : (val) async {
                          setState(() => isUpdatingActive = true);
                          await beautyCenterDB
                              .child(beautyCenter!.uid)
                              .update({'isActive': val});
                          setState(() {
                            beautyCenter =
                                beautyCenter!.copyWith(isActive: val);
                            isUpdatingActive = false;
                          });
                        },
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.white54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Profile Dialog (unchanged) ────────────────────────────────────────
  Widget _editProfileDialog() => Dialog(
        backgroundColor: _kDark2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .15)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: _blue2, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _DarkField(
                          ctrl: firstNameController,
                          label: 'الاسم الأول',
                          icon: Icons.person_outline_rounded,
                          accent: _blue2),
                      const SizedBox(height: 10),
                      _DarkField(
                          ctrl: lastNameController,
                          label: 'اسم العائلة',
                          icon: Icons.person_outline_rounded,
                          accent: _blue2),
                      const SizedBox(height: 10),
                      _DarkField(
                          ctrl: emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          accent: _blue2,
                          keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _DarkField(
                          ctrl: phoneController,
                          label: 'رقم الهاتف',
                          icon: Icons.phone_outlined,
                          accent: _blue2,
                          keyboard: TextInputType.phone),
                      const SizedBox(height: 10),
                      _DarkField(
                          ctrl: addressController,
                          label: 'العنوان',
                          icon: Icons.location_on_outlined,
                          accent: _blue2),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: .15)),
                          ),
                          child: Center(
                            child: Text('إلغاء',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: .5),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: updateProfile,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                                colors: [_blue, _blue2]),
                            boxShadow: [
                              BoxShadow(
                                  color: _blue.withValues(alpha: .4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Center(
                            child: Text('حفظ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  // ── Edit Services Dialog (unchanged) ───────────────────────────────────────
  Widget _editServicesDialog() {
    List<Map<String, dynamic>> editableServices = beautyCenter!.services
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return StatefulBuilder(
      builder: (context, setS) => Dialog(
        backgroundColor: _kDark,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .15)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.design_services_rounded,
                          color: _blue2, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('تعديل الخدمات',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  editableServices.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DarkFieldRaw(
                            init: editableServices[i]['name'],
                            label: 'اسم الخدمة',
                            accent: _blue2,
                            onChanged: (v) => editableServices[i]['name'] = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: _DarkFieldRaw(
                            init: editableServices[i]['price'],
                            label: 'السعر',
                            accent: _blue2,
                            keyboard: TextInputType.number,
                            onChanged: (v) => editableServices[i]['price'] = v,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () =>
                              setS(() => editableServices.removeAt(i)),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setS(
                      () => editableServices.add({'name': '', 'price': ''})),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _blue2.withValues(alpha: .4), width: 1.5),
                      color: Colors.white.withValues(alpha: .04),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: _blue2, size: 18),
                        SizedBox(width: 6),
                        Text('إضافة خدمة',
                            style: TextStyle(
                                color: _blue2,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await beautyCenterDB.child(beautyCenter!.uid).update(
                        {'services': editableServices});
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [_blue, _blue2]),
                      boxShadow: [
                        BoxShadow(
                            color: _blue.withValues(alpha: .4),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Center(
                      child: Text('حفظ التعديلات',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ██  NEW: Edit Doctors Dialog
  // ══════════════════════════════════════════════════════════════════════════
  Widget _editDoctorsDialog() {
    // Load current doctors from Firebase
    List<Map<String, dynamic>> editableDoctors = [];

    return StatefulBuilder(
      builder: (ctx, setS) {
        // ── Load on first build ──
        if (editableDoctors.isEmpty) {
          FirebaseDatabase.instance
              .ref('BeautyCenter/${beautyCenter!.uid}/doctors')
              .get()
              .then((snap) {
            final List<Map<String, dynamic>> loaded = [];
            if (snap.value is List) {
              for (final item in (snap.value as List)) {
                if (item != null)
                  loaded.add(Map<String, dynamic>.from(item as Map));
              }
            } else if (snap.value is Map) {
              (snap.value as Map).forEach((_, v) {
                if (v is Map) loaded.add(Map<String, dynamic>.from(v));
              });
            }
            setS(() => editableDoctors = loaded);
          });
        }

        return Dialog(
          backgroundColor: _kDark,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: .15)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_kAccent, _blue2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                                color: _kAccent.withValues(alpha: .3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: const Icon(Icons.medical_services_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('إدارة الأطباء',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            Text('حدد اليوم، الاسم، التخصص والتوقيت',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Doctor rows ──────────────────────────────────────
                  if (editableDoctors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(Icons.person_add_outlined,
                              color: Colors.white.withValues(alpha: .2),
                              size: 40),
                          const SizedBox(height: 8),
                          Text('لا يوجد أطباء بعد، أضف أول طبيب',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: .35),
                                  fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...List.generate(editableDoctors.length, (i) {
                      final doc = editableDoctors[i];
                      return _DoctorEditRow(
                        key: ValueKey(i),
                        doctor: doc,
                        dayNames: _kDayNames,
                        onChanged: (updated) =>
                            setS(() => editableDoctors[i] = updated),
                        onDelete: () =>
                            setS(() => editableDoctors.removeAt(i)),
                      );
                    }),

                  const SizedBox(height: 12),

                  // ── Add doctor button ────────────────────────────────
                  GestureDetector(
                    onTap: () => setS(() => editableDoctors.add({
                          'day': 1,
                          'name': '',
                          'specialty': '',
                          'from': '',
                          'to': '',
                        })),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _kAccent.withValues(alpha: .4), width: 1.5),
                        color: _kAccent.withValues(alpha: .06),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded,
                              color: _kAccent, size: 18),
                          SizedBox(width: 8),
                          Text('إضافة طبيب / مختص',
                              style: TextStyle(
                                  color: _kAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Save / Cancel ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: .15)),
                            ),
                            child: Center(
                              child: Text('إلغاء',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: .5),
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            await FirebaseDatabase.instance
                                .ref(
                                    'BeautyCenter/${beautyCenter!.uid}/doctors')
                                .set(editableDoctors);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnack(
                                'تم حفظ بيانات الأطباء بنجاح ✅', Colors.green);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                  colors: [_kAccent, _blue2]),
                              boxShadow: [
                                BoxShadow(
                                    color: _kAccent.withValues(alpha: .4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: const Center(
                              child: Text('حفظ الأطباء',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _kDark2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .15)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 14),
              const Text('تسجيل الخروج',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('هل تريد تسجيل الخروج؟',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                      fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: .12)),
                        ),
                        child: Center(
                          child: Text('إلغاء',
                              style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: .5))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.redAccent.withValues(alpha: .4),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Center(
                          child: Text('تسجيل الخروج',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        GoRouter.of(context)
            .pushReplacement(AppRouter.kServicesSelectionView);
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ██  NEW: Doctor Edit Row Widget
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorEditRow extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final Map<int, String> dayNames;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onDelete;

  const _DoctorEditRow({
    super.key,
    required this.doctor,
    required this.dayNames,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_DoctorEditRow> createState() => _DoctorEditRowState();
}

class _DoctorEditRowState extends State<_DoctorEditRow> {
  static const _kAccent = Color(0xFF7EDBD5);
  static const _blue2 = Color(0xFF1A8A84);

  late TextEditingController _nameCtrl;
  late TextEditingController _specCtrl;
  late TextEditingController _fromCtrl;
  late TextEditingController _toCtrl;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.doctor['day'] as int? ?? 1;
    _nameCtrl =
        TextEditingController(text: widget.doctor['name'] as String? ?? '');
    _specCtrl =
        TextEditingController(text: widget.doctor['specialty'] as String? ?? '');
    _fromCtrl =
        TextEditingController(text: widget.doctor['from'] as String? ?? '');
    _toCtrl =
        TextEditingController(text: widget.doctor['to'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged({
      'day': _selectedDay,
      'name': _nameCtrl.text.trim(),
      'specialty': _specCtrl.text.trim(),
      'from': _fromCtrl.text.trim(),
      'to': _toCtrl.text.trim(),
    });
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _kAccent,
            onPrimary: Colors.white,
            surface: Color(0xFF1A1A2E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAccent.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Day Dropdown + Delete ──────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kAccent.withValues(alpha: .3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedDay,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(
                        color: _kAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                    icon: const Icon(Icons.expand_more_rounded,
                        color: _kAccent, size: 16),
                    items: widget.dayNames.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedDay = v);
                        _notify();
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: .3)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Name ────────────────────────────────────────────────────
          _DarkFieldRaw(
            init: _nameCtrl.text,
            label: 'اسم الطبيب / المختص',
            accent: _blue2,
            onChanged: (v) {
              _nameCtrl.text = v;
              _notify();
            },
          ),
          const SizedBox(height: 8),

          // ── Specialty ───────────────────────────────────────────────
          _DarkFieldRaw(
            init: _specCtrl.text,
            label: 'التخصص',
            accent: _blue2,
            onChanged: (v) {
              _specCtrl.text = v;
              _notify();
            },
          ),
          const SizedBox(height: 8),

          // ── Time from / to ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(_fromCtrl),
                  child: AbsorbPointer(
                    child: _DarkFieldRaw(
                      init: _fromCtrl.text,
                      label: 'من (توقيت)',
                      accent: _kAccent,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('–',
                  style: TextStyle(color: Colors.white38, fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(_toCtrl),
                  child: AbsorbPointer(
                    child: _DarkFieldRaw(
                      init: _toCtrl.text,
                      label: 'إلى (توقيت)',
                      accent: _kAccent,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared widgets (unchanged)
// ──────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text('$label:  ',
                style:
                    const TextStyle(color: Colors.white60, fontSize: 13)),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.white.withValues(alpha: .07), height: 1);
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: ScaleTransition(
          scale: _s,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.color.withValues(alpha: .12),
              border: Border.all(
                  color: widget.color.withValues(alpha: .3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.color, size: 18),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final Color accent;
  final TextInputType keyboard;
  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.accent,
    this.keyboard = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withValues(alpha: .45), fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.white38, size: 18),
          filled: true,
          fillColor: Colors.white.withValues(alpha: .07),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: accent.withValues(alpha: .7), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      );
}

class _DarkFieldRaw extends StatelessWidget {
  final String? init;
  final String label;
  final Color accent;
  final TextInputType keyboard;
  final Function(String) onChanged;
  const _DarkFieldRaw({
    this.init,
    required this.label,
    required this.accent,
    this.keyboard = TextInputType.text,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: init,
        keyboardType: keyboard,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          labelStyle: TextStyle(
              color: Colors.white.withValues(alpha: .4), fontSize: 12),
          filled: true,
          fillColor: Colors.white.withValues(alpha: .07),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: .1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: accent.withValues(alpha: .7), width: 1.5),
          ),
        ),
      );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: .12),
        ),
      );
}