import 'package:flutter/material.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/views/doctor_chat_list_view.dart';
import 'package:sehha_app/views/doctor_profile_view.dart';
import 'package:sehha_app/views/doctor_requests_view.dart';

class DoctorView extends StatefulWidget {
  const DoctorView({super.key});

  @override
  State<DoctorView> createState() => _DoctorViewState();
}

class _DoctorViewState extends State<DoctorView> {
  int currentIndex = 0;
  final List<Widget> screens = const [
    DoctorRequestView(),
    DoctorChatListView(),
    DoctorProfileView(),
  ];
  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        selectedItemColor: AppColors.scondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: local.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: local.translate('chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: local.translate('profile'),
          ),
        ],
      ),
    );
  }
}
