import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehha_app/core/services/fcm_service.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/core/cubit/cart_cubit/cart_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late SharedPreferences prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lcmktpnqevkbhugwwglg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjbWt0cG5xZXZrYmh1Z3d3Z2xnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTY3NjIxMiwiZXhwIjoyMDg3MjUyMjEyfQ.us1gkIowvhTzYkb4I94n0Hz5OKIooTIk-VoI7xtF_mI',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  prefs = await SharedPreferences.getInstance();
  await FcmService.init();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<CartCubit>(create: (_) => CartCubit())],
      child: const CurlyApp(),
    ),
  );
  ;
}

class CurlyApp extends StatefulWidget {
  const CurlyApp({super.key});
  static CurlyAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<CurlyAppState>();
    if (state == null) {
      throw Exception('CurlyAppState not found in context');
    }
    return state;
  }

  @override
  State<CurlyApp> createState() => CurlyAppState();
}

class CurlyAppState extends State<CurlyApp> {
  Locale? _locale = const Locale('ar');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    GoTransition.defaultCurve = Curves.easeInOut;
    GoTransition.defaultReverseDuration = const Duration(seconds: 1);

    return MaterialApp.router(
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (_locale == null) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale?.languageCode) {
              return locale;
            }
          }
        }
        return _locale ?? supportedLocales.first;
      },

      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 480, name: MOBILE),
            Breakpoint(start: 481, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1200, name: DESKTOP),
            Breakpoint(start: 1201, end: double.infinity, name: '4K'),
          ],
        );
      },

      theme: ThemeData(
        fontFamily: 'Cairo',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
