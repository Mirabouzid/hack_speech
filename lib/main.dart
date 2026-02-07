import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hack_speech/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  await Hive.openBox(AppConstants.settingsKey);
  await Hive.openBox(AppConstants.userKey);
  await Hive.openBox(AppConstants.tokenKey);

  try {
    EnvConfig.validateConfig();
    debugPrint('✅ Configuration validée');
  } catch (e) {
    debugPrint('⚠️ Erreur de configuration: $e');
  }

  runApp(const ProviderScope(child: AmiraBouzidApp()));
}

class AmiraBouzidApp extends ConsumerWidget {
  const AmiraBouzidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryPurple,
          secondary: AppColors.accentYellow,
          error: AppColors.accentRed,
          surface: AppColors.background,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryPurple,
              width: 2,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const OnboardingScreen(),
    );
  }
}
