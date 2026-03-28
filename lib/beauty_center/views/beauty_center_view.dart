// import 'package:flutter/material.dart';
// import 'package:sehha_app/beauty_center/views/beauty_center_chat_list_view.dart';
// import 'package:sehha_app/beauty_center/views/beauty_center_profile_view.dart';
// import 'package:sehha_app/beauty_center/views/beauty_center_requests_view.dart';
// import 'package:sehha_app/beauty_center/views/customer_chat_list.dart';
// import 'package:sehha_app/store/views/store_view.dart';
// import 'package:sehha_app/views/support_and_payment_view.dart';
// import '../../core/utils/app_colors.dart';

// class BeautyCenterView extends StatefulWidget {
//   const BeautyCenterView({super.key});

//   @override
//   State<BeautyCenterView> createState() => _BeautyCenterViewState();
// }

// class _BeautyCenterViewState extends State<BeautyCenterView> {
//   int currentIndex = 0;

//   void goToStore() {
//     setState(() {
//       currentIndex = 2;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> screens = [
//       const BeautyCenterRequestsView(),
//       const BeautyCenterChatListView(),
//       StoreView(onGoBackFromOrder: goToStore),
//       const SupportAndPaymentView(),
//       const BeautyCenterProfileView(),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: currentIndex, children: screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: currentIndex,
//         onTap: (index) => setState(() => currentIndex = index),
//         selectedItemColor: BeautyCenterAppColors.secondaryColor,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الدردشة'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'المتجر',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.support_agent),
//             label: 'خدمة العملاء',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'الملف الشخصي',
//           ),
//         ],
//       ),
//     );
//   }
// }
