import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramazaan_tracker/features/zikr/providers/zikr_provider.dart';
import 'core/constants/app_colors.dart';
import 'core/services/storage_service.dart';
import 'features/onboarding/providers/user_provider.dart';
import 'features/home/providers/daily_progress_provider.dart';
import 'features/tilawat/providers/tilawat_provider.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await StorageService.init();

  runApp(const RamazanTrackerApp());
}

class RamazanTrackerApp extends StatelessWidget {
  const RamazanTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Make UserProvider available throughout the app
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => DailyProgressProvider()),
        ChangeNotifierProvider(create: (_) => ZikrProvider()),
        ChangeNotifierProvider(create: (_) => TilawatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ramazan Amaal Tracker',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            surface: AppColors.scaffoldBackground,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}