import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehha_app/admin/cubit/cubit/admin_state.dart';
import 'package:sehha_app/core/tools/constants.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit() : super(AdminAuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AdminAuthLoading());

    if (email.trim() != adminEmail) {
      emit(AdminAuthError('غير مسموح بالدخول'));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(AdminAuthSuccess());
    } catch (e) {
      emit(AdminAuthError('بيانات الدخول غير صحيحة'));
    }
  }
}
