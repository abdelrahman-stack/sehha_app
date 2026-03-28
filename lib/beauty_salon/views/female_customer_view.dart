// import 'package:flutter/material.dart';
// import 'package:sehha_app/beauty_salon/views/famale_customer_chat_list.dart';
// import 'package:sehha_app/beauty_salon/views/famale_customer_profile_view.dart';
// import 'package:sehha_app/beauty_salon/views/female_hairdresser_list_view.dart';
// import 'package:sehha_app/store/views/store_view.dart';
// import 'package:sehha_app/views/support_and_payment_view.dart';
// import '../../core/utils/app_colors.dart';

// class FemaleCustomerView extends StatefulWidget {
//   const FemaleCustomerView({super.key});

//   @override
//   State<FemaleCustomerView> createState() => _FemaleCustomerViewState();
// }

// class _FemaleCustomerViewState extends State<FemaleCustomerView> {
//   int currentIndex = 0;

//   void goToStore() {
//     setState(() {
//       currentIndex = 2; 
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> screens = [
//       const FemaleHairdresserListView(),
//       const FemaleCustomerChatList(),
//       StoreView(onGoBackFromOrder: goToStore),
//       const SupportAndPaymentView(),
//       const FemaleCustomerProfileView(),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: currentIndex, children: screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: currentIndex,
//         onTap: (index) => setState(() => currentIndex = index),
//         selectedItemColor: FemaleAppColors.secondaryColor,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'الرئيسية',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'الدردشة',
//           ),
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
