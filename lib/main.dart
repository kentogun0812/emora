// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/colors.dart';
import 'core/constants/routes.dart';
import 'core/network/supabase_handler.dart';
import 'core/utils/localization.dart';
import 'features/auth/bloc/auth_bloc.dart';
// import 'features/auth/screens/login_screen.dart';
// import 'features/auth/screens/splash_screen.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/pairing/bloc/pairing_bloc.dart';
import 'features/calendar/bloc/calendar_bloc.dart';
import 'features/calendar/bloc/calendar_event.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase connection from compile-time environment variables
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-supabase-project.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );

  await SupabaseHandler.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const EmoraApp());
}

class EmoraApp extends StatelessWidget {
  const EmoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<PairingBloc>(
          create: (context) => PairingBloc(),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc()..add(const LoadDashboard()),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc()..add(const LoadCalendar()),
        ),
      ],
      child: MaterialApp(
        title: 'Emora',
        debugShowCheckedModeBanner: false,

        // Configure light theme & Outfit font
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: EmoraColors.background,
          primaryColor: EmoraColors.primary,
          colorScheme: const ColorScheme.light(
            primary: EmoraColors.primary,
            secondary: EmoraColors.secondary,
            surface: EmoraColors.surface,
          ),
        ),

        // Configure multi-language localization support
        supportedLocales: const [
          Locale('vn', ''), // Vietnamese
          Locale('en', ''), // English
          Locale('ko', ''), // Korean
          Locale('jp', ''), // Japanese
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('vn', ''); // Default to Vietnamese
        },

        // Screen routing management
        initialRoute: EmoraRoutes.dashboard,
        routes: {
          EmoraRoutes.splash: (context) => const DashboardScreen(),
          EmoraRoutes.login: (context) => const DashboardScreen(),
          EmoraRoutes.pairing: (context) => const DashboardScreen(),
          EmoraRoutes.dashboard: (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
