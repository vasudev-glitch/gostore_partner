import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:gostore_partner/screens/login_screen.dart';
import 'package:gostore_partner/screens/profile_screen.dart';
import 'package:gostore_partner/screens/splash_screen.dart';
import 'package:gostore_partner/firebase_options.dart';
import 'package:gostore_partner/utils/ui_config.dart'; // ✅ Centralized UI styles

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'GoStore Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: AppTextStyle.headingLarge(context),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: AppTextStyle.body(context),
          bodyMedium: AppTextStyle.body(context),
          labelLarge: AppTextStyles.button,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonStyles.primary,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}
