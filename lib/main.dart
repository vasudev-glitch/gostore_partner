import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeData = await loadRemoteTheme(); // Load theme from Firestore
  runApp(MyApp(themeData: themeData));
}

class MyApp extends StatelessWidget {
  final ThemeData themeData;
  const MyApp({super.key, required this.themeData});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'GoStore Partner',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const SplashScreen(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}

Future<ThemeData> loadRemoteTheme() async {
  try {
    final doc = await FirebaseFirestore.instance.collection("themes").doc("default").get();
    final data = doc.data();

    if (data == null) return ThemeData.light();

    final isDark = data['brightness'] == 'dark';

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: HexColor(data['backgroundColor'] ?? "#FFFFFF"),
      colorScheme: ColorScheme.fromSeed(seedColor: HexColor(data['primaryColor'] ?? "#0A2540")),
      appBarTheme: AppBarTheme(
        backgroundColor: HexColor(data['appBarColor'] ?? "#0A2540"),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.getFont(
          data['fontFamily'] ?? 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.getFont(data['fontFamily'] ?? 'Poppins', fontSize: 14),
        bodyMedium: GoogleFonts.getFont(data['fontFamily'] ?? 'Poppins', fontSize: 14),
        labelLarge: GoogleFonts.getFont(data['fontFamily'] ?? 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(data['buttonColor'] ?? "#01E0AC"),
          foregroundColor: HexColor(data['buttonTextColor'] ?? "#000000"),
          textStyle: GoogleFonts.getFont(data['fontFamily'] ?? 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  } catch (e) {
    debugPrint("⚠️ Theme load failed: $e");
    return ThemeData.light();
  }
}

class HexColor extends Color {
  HexColor(String hexColor) : super(_getColorFromHex(hexColor));
  static int _getColorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }
}
