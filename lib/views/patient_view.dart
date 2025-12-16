import 'package:flutter/material.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/views/chat_list.dart';
import 'package:sehha_app/views/docto_list_view.dart';
import 'package:sehha_app/views/patient_profile_view.dart';

class PatientView extends StatefulWidget {
  const PatientView({super.key});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const DoctorListView(),
    const ChatList(),
    const PatientProfileView(),
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
      body: IndexedStack(index: currentIndex, children: screens),
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
