  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:go_transitions/go_transitions.dart';
  import 'package:sehha_app/core/tools/app_localizations%20.dart';
  import 'package:sehha_app/core/utils/app_router.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:flutter_localizations/flutter_localizations.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://sioaywyvghkapxgnczgu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpb2F5d3l2Z2hrYXB4Z25jemd1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MjU5MTkxMywiZXhwIjoyMDY4MTY3OTEzfQ.w7HCb5reZglAy0ixcUW96fFn3x5iWBR2jExKaKm4Hk8',
    );

    await Firebase.initializeApp();

    runApp(const SehhaApp());
  }

  class SehhaApp extends StatefulWidget {
    const SehhaApp({super.key});
    static SehhaAppState of(BuildContext context) {
      final state = context.findAncestorStateOfType<SehhaAppState>();
      if (state == null) {
        throw Exception('SehhaAppState not found in context');
      }
      return state;
    }

    @override
    State<SehhaApp> createState() => SehhaAppState();
  }

  class SehhaAppState extends State<SehhaApp> {
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
