import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future<void> saveUserLoginState(String uid, String userType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('uid', uid);
  await prefs.setString('userType', userType);
  await prefs.setBool('isLoggedIn', true);
}


Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
  // await prefs.remove('uid');
  // await prefs.remove('userType');
  // await prefs.remove('isLoggedIn');

  GoRouter.of(context).pushReplacement(
    AppRouter.kServicesSelectionView,
  );
}
