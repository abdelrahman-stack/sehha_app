// GoRouter configuration
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:sehha_app/models/doctor_model.dart';
import 'package:sehha_app/views/all_doctor_view.dart';
import 'package:sehha_app/views/all_doctors_by_category_view.dart';
import 'package:sehha_app/views/all_specialties_view.dart';
import 'package:sehha_app/views/chat_view.dart';
import 'package:sehha_app/views/docto_list_view.dart';
import 'package:sehha_app/views/doctor_details_view.dart';
import 'package:sehha_app/views/doctor_view.dart';
import 'package:sehha_app/views/my_bookings_view.dart';
import 'package:sehha_app/views/patient_view.dart';
import 'package:sehha_app/views/signin_view.dart';
import 'package:sehha_app/views/signup_view.dart';
import 'package:sehha_app/views/splash_view.dart';

class AppRouter {
  static const kSigninView = '/signinView';
  static const kSignupView = '/signupView';
  static const kDoctorView = '/doctorView';
  static const kPatientView = '/patientView';
  static const kDoctorDetailsView = '/DoctorDetailsView';
  static const kDoctorListView = '/DoctorListView';
  static const kChatView = '/ChatView';
  static const kAllDoctorsView = '/kAllDoctors';
  static const kAllSpecialtiesView = '/kAllSpecialties';
  static const kAllDoctorsByCategoryView = '/kAllDoctorsByCategory';
  static const kMyBookingsView = '/kMyBookingsView';

  static final router = GoRouter(
    observers: [GoTransition.observer],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
        pageBuilder: GoTransitions.fadeUpwards,
      ),
      GoRoute(
        path: kSigninView,
        builder: (context, state) => const SigninView(),
        pageBuilder: GoTransitions.slide.toRight.withFade,
      ),

      GoRoute(
        path: kSignupView,
        builder: (context, state) => const SignupView(),
        pageBuilder: GoTransitions.openUpwards,
      ),
      GoRoute(
        path: kDoctorListView,
        builder: (context, state) => const DoctorListView(),
        pageBuilder: GoTransitions.scale.withFade,
      ),
      GoRoute(
        path: kDoctorView,

        builder: (context, state) {
          return const DoctorView();
        },
        pageBuilder: GoTransitions.fadeUpwards,
      ),
      GoRoute(
        path: kPatientView,

        builder: (context, state) {
          return const PatientView();
        },
        pageBuilder: GoTransitions.scale,
      ),
      GoRoute(
        path: kDoctorDetailsView,
        builder: (context, state) =>
            DoctorDetailsView(doctorModel: state.extra as DoctorModel),
        pageBuilder: GoTransitions.bottomSheet,
      ),
      GoRoute(
        path: AppRouter.kChatView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ChatView(
            doctorName: data['doctorName'],
            doctorId: data['doctorId'],
            patientName: data['patientName'],
            patientId: data['patientId'],
          );
        },
      ),

      GoRoute(
        path: kAllDoctorsView,
        builder: (context, state) => const AllDoctorsView(),
        pageBuilder: GoTransitions.scale.withFade,
      ),
      GoRoute(
        path: kAllSpecialtiesView,
        builder: (context, state) => const AllSpecialtiesView(),
        pageBuilder: GoTransitions.slide.toRight.withFade,
      ),
      GoRoute(
        path: kAllDoctorsByCategoryView,
        builder: (context, state) =>
            AllDoctorsByCategoryView(category: state.extra as String),
        pageBuilder: GoTransitions.slide.toRight.withFade,
      ),

      GoRoute(
        path: '/kMyBookingsView',
        builder: (context, state) => const MyBookingsView(),
      ),
    ],
  );
}
