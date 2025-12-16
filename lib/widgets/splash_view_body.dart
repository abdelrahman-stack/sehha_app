import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthUser();
    });
  }

  Future<void> checkAuthUser() async {
    await Future.delayed(const Duration(seconds: 2));

    User? user = auth.currentUser;

    if (user == null) {
      GoRouter.of(context).pushReplacement(AppRouter.kSigninView);
      return;
    }

    DatabaseReference userRef = database.child('Doctors').child(user.uid);
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      GoRouter.of(context).pushReplacement(AppRouter.kDoctorView);
    } else {
      userRef = database.child('Patients').child(user.uid);
      snapshot = await userRef.get();
      if (snapshot.exists) {
        GoRouter.of(context).pushReplacement(AppRouter.kPatientView);
      } else {
        GoRouter.of(context).pushReplacement(AppRouter.kSigninView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              textAlign: TextAlign.end,
              local.translate('D+'),
              style:const TextStyle(
                color: AppColors.scondaryColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              textAlign: TextAlign.end,
              local.translate('The Future of Healthcare\n in Your Hands'),
              style:const TextStyle(color: AppColors.scondaryColor, fontSize: 28),
            ),
            const Spacer(flex: 1),
            SvgPicture.asset('assets/images/Medinova.svg', height: 250),
            Text(
              textAlign: TextAlign.center,
              local.translate('sehha'),
              style:const TextStyle(
                color: AppColors.scondaryColor,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
