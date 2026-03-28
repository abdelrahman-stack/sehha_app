// GoRouter configuration
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:sehha_app/admin/views/admin_dashboard_view.dart';
import 'package:sehha_app/admin/views/widgets/add_edit_product_view.dart';
import 'package:sehha_app/auth/beauty_center_auth_view.dart';
import 'package:sehha_app/auth/beauty_center_signin.dart';
import 'package:sehha_app/auth/beauty_center_signup.dart';
import 'package:sehha_app/auth/famale_auth_view.dart';
import 'package:sehha_app/auth/famale_signin.dart';
import 'package:sehha_app/auth/famale_signup.dart';
import 'package:sehha_app/auth/male_auth_view.dart';
import 'package:sehha_app/auth/male_signin.dart';
import 'package:sehha_app/auth/male_signup.dart';
import 'package:sehha_app/beauty_center/views/beauty_center_details_view.dart';
import 'package:sehha_app/beauty_center/views/beauty_center_view.dart';
import 'package:sehha_app/beauty_center/views/customer_view.dart';
import 'package:sehha_app/beauty_salon/views/service_famale_details_view.dart';
import 'package:sehha_app/core/models/provider_service_model.dart';
import 'package:sehha_app/store/views/order_summary_view.dart';
import 'package:sehha_app/store/views/store_view.dart';
import 'package:sehha_app/barber/views/barber_view.dart';
import 'package:sehha_app/views/chat_view.dart';
import 'package:sehha_app/barber/views/service_male_details_view.dart';
import 'package:sehha_app/beauty_salon/views/female_customer_view.dart';
import 'package:sehha_app/beauty_salon/views/hairdesser_view.dart';
import 'package:sehha_app/barber/views/male_customer_view.dart';
import 'package:sehha_app/views/my_bookings_view.dart';
import 'package:sehha_app/views/services_selection_view.dart';
import 'package:sehha_app/views/splash_view.dart';
import 'package:sehha_app/views/support_and_payment_view.dart';

class AppRouter {
  static const kFemaleCustomerView = '/femaleCustomerView';
  static const kMaleCustomerView = '/maleCustomerView';
  static const kServiceMaleDetailsView = '/serviceMaleDetailsView';
  static const kServiceFemaleDetailsView = '/serviceFemaleDetailsView';
  static const kChatView = '/ChatView';
  static const kMaleAuthView = '/maleAuthView';
  static const kFemaleAuthView = '/femaleAuthView';
  static const kServicesSelectionView = '/kServicesSelectionView';
  static const kMyBookingsView = '/kMyBookingsView';
  static const kBarberView = '/barberView';
  static const kHairdresserView = '/hairdresserView';
  static const kFemaleSignUpView = '/femaleSignUpView';
  static const kMaleSignUpView = '/maleSignUpView';
  static const kFemaleSignInView = '/femaleSignInView';
  static const kMaleSignInView = '/maleSignInView';
  static const kMainView = '/mainView';
  static const kAdminDashboardView = '/adminDashboardView';
  static const kAddEditProductView = '/addEditProductView';
  static const kStoreView = '/storeView';
  static const kOrderSummaryView = '/orderSummary';
  static const kSupportAndPaymentView = '/supportAndPaymentView';
  static const kCustomerView = '/customerView';
  static const kBeautyCenterDetailsView = '/beautyCenterDetailsView';
  static const kBeautyCenterAuthView = '/beautyCenterAuthView';
  static const kBeautyCenterView = '/beautyCenterView';
  static const kBeautyCenterSignUp = '/beautyCenterSignUp';
  static const kBeautyCenterSignIn = '/beautyCenterSignIn';

  static final router = GoRouter(
    observers: [GoTransition.observer],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),
      GoRoute(
        path: kOrderSummaryView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OrderSummaryView(
            paymentMethod: data['paymentMethod'],
            name: data['name'],
            phone: data['phone'],
            address: data['address'],
          );
        },
        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
      ),

      GoRoute(
        path: kMaleSignInView,
        builder: (context, state) => const MaleSignInView(),
        pageBuilder: GoTransitions.slide.toRight.withFade.call,
      ),
      GoRoute(
        path: kFemaleSignInView,
        builder: (context, state) => const FemaleSignInView(),
        pageBuilder: GoTransitions.slide.toRight.withFade.call,
      ),
      GoRoute(
        path: kBeautyCenterSignIn,
        builder: (context, state) => const BeautyCenterSignin(),
        pageBuilder: GoTransitions.slide.toRight.withFade.call,
      ),
      GoRoute(
        path: kAddEditProductView,
        builder: (context, state) => const AddEditProductView(),
        pageBuilder: GoTransitions.slide.toRight.withFade.call,
      ),
      GoRoute(
        path: kMaleSignUpView,
        builder: (context, state) => const MaleSignUpView(),
        pageBuilder: GoTransitions.openUpwards.call,
      ),
      GoRoute(
        path: kFemaleSignUpView,
        builder: (context, state) => const FemaleSignUpView(),
        pageBuilder: GoTransitions.openUpwards.call,
      ),
      GoRoute(
        path: kBeautyCenterSignUp,
        builder: (context, state) => const BeautyCenterSignup(),
        pageBuilder: GoTransitions.openUpwards.call,
      ),

      GoRoute(
        path: kServicesSelectionView,

        builder: (context, state) => const ServicesSelectionView(),
        pageBuilder: GoTransitions.scale.withFade.call,
      ),
      GoRoute(
        path: kStoreView,
        builder: (context, state) => const StoreView(),
        pageBuilder: GoTransitions.scale.withRotation.call,
      ),
      GoRoute(
        path: kSupportAndPaymentView,
        builder: (context, state) => const SupportAndPaymentView(),
        pageBuilder: GoTransitions.scale.withRotation.call,
      ),

      GoRoute(
        path: kAdminDashboardView,
        builder: (context, state) => const AdminDashboardView(),
        pageBuilder: GoTransitions.scale.withFade.call,
      ),
      GoRoute(
        path: kMaleAuthView,

        builder: (context, state) {
          return const MaleAuthView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),
      GoRoute(
        path: kFemaleAuthView,

        builder: (context, state) {
          return const FemaleAuthView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),
      GoRoute(
        path: kBeautyCenterAuthView,

        builder: (context, state) {
          return const BeautyCenterAuthView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),
      GoRoute(
        path: kBarberView,

        builder: (context, state) {
          return const BarberView();
        },
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),
      GoRoute(
        path: kHairdresserView,

        builder: (context, state) {
          return const HairdresserView();
        },
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),
      GoRoute(
        path: kBeautyCenterView,

        builder: (context, state) {
          return const BeautyCenterView();
        },
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),
      GoRoute(
        path: kFemaleCustomerView,

        builder: (context, state) {
          return const FemaleCustomerView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),
      GoRoute(
        path: kServiceFemaleDetailsView,
        builder: (context, state) => ServicesFemaleDetailsView(
          doctorModel: state.extra as ProviderServiceModel,
        ),
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),
      GoRoute(
        path: kCustomerView,

        builder: (context, state) {
          return const CustomerView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),
      GoRoute(
        path: kMaleCustomerView,

        builder: (context, state) {
          return const MaleCustomerView();
        },
        pageBuilder: GoTransitions.scale.call,
      ),

      GoRoute(
        path: kServiceMaleDetailsView,
        builder: (context, state) => ServicesMaleDetailsView(
          doctorModel: state.extra as ProviderServiceModel,
        ),
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),

      GoRoute(
        path: kBeautyCenterDetailsView,
        builder: (context, state) => BeautyCenterDetailsView(
          serviceModel: state.extra as ProviderServiceModel,
        ),
        pageBuilder: GoTransitions.bottomSheet,
      ),

      GoRoute(
        path: AppRouter.kChatView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final myId = data['myId'] as String;
          final otherUserId = data['otherUserId'] as String;
          final chatId = (myId.compareTo(otherUserId) < 0)
              ? "$myId-$otherUserId"
              : "$otherUserId-$myId";

          return ChatView(
            myId: myId,
            otherUserId: otherUserId,
            otherUserName: data['otherUserName'] as String,
            chatId: chatId,
          );
        },
        pageBuilder: GoTransitions.fadeUpwards.call,
      ),

      GoRoute(
        path: '/kMyBookingsView',
        builder: (context, state) => const MyBookingsView(),
      ),
    ],
  );
}
