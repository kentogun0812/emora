// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'core/constants/routes.dart';
import 'core/network/supabase_handler.dart';
import 'core/utils/localization.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/pairing/bloc/pairing_bloc.dart';
import 'features/pairing/screens/pairing_screen.dart';
import 'features/calendar/bloc/calendar_bloc.dart';
import 'features/calendar/bloc/calendar_event.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/vent/bloc/vent_bloc.dart';
import 'features/vent/screens/vent_room_screen.dart';
import 'features/baby/bloc/baby_bloc.dart';
import 'features/baby/bloc/baby_event.dart';
import 'features/baby/screens/baby_setup_screen.dart';
import 'features/baby/screens/vaccine_tracker_screen.dart';
import 'features/settings/bloc/theme_bloc.dart';
import 'features/settings/bloc/theme_state.dart';
import 'features/settings/screens/premium_paywall_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'core/utils/auth_guard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hydrated storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  // Initialize Supabase connection from compile-time environment variables
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-supabase-project.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );

  if (kDebugMode) {
    print('EMORA_DEBUG: supabaseUrl = $supabaseUrl');
    print('EMORA_DEBUG: supabaseAnonKey = ${supabaseAnonKey.isNotEmpty ? (supabaseAnonKey.length > 20 ? "${supabaseAnonKey.substring(0, 10)}..." : supabaseAnonKey) : "EMPTY"}');
  }

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
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
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
        BlocProvider<VentBloc>(
          create: (context) => VentBloc(),
        ),
        BlocProvider<BabyBloc>(
          create: (context) => BabyBloc()..add(const LoadBabyProfile()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final colors = themeState.themeColors;

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Emora',
            debugShowCheckedModeBanner: false,

            // Configure light theme dynamically
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: colors.background,
              primaryColor: colors.primary,
              colorScheme: ColorScheme.light(
                primary: colors.primary,
                secondary: colors.secondary,
                surface: colors.surface,
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
            initialRoute: EmoraRoutes.splash,
            routes: {
              EmoraRoutes.splash: (context) => const SplashScreen(),
              EmoraRoutes.login: (context) => const LoginScreen(),
              EmoraRoutes.signup: (context) => const SignUpScreen(),
              EmoraRoutes.pairing: (context) => const PairingScreen(),
              EmoraRoutes.dashboard: (context) => const DashboardScreen(),
              EmoraRoutes.ventRoom: (context) => const VentRoomScreen(),
              EmoraRoutes.babySetup: (context) => const BabySetupScreen(),
              EmoraRoutes.vaccineTracker: (context) => const VaccineTrackerScreen(),
              EmoraRoutes.premiumPaywall: (context) => const PremiumPaywallScreen(),
              EmoraRoutes.onboarding: (context) => const OnboardingScreen(),
              EmoraRoutes.profileSetup: (context) => const ProfileSetupScreen(),
            },
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (!GlobalAuthGuard.initialNavigationDone) return;

                  if (state is AuthUnauthenticated) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      EmoraRoutes.login,
                      (route) => false,
                    );
                  } else if (state is AuthSuccessNeedsProfileSetup) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      EmoraRoutes.profileSetup,
                      (route) => false,
                    );
                  } else if (state is AuthSuccessUnpaired) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      EmoraRoutes.dashboard,
                      (route) => false,
                    );
                  } else if (state is AuthSuccessPaired) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      EmoraRoutes.dashboard,
                      (route) => false,
                    );
                  }
                },
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
