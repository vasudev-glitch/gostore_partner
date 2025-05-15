import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:gostore_partner/utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), _checkAuthStatus);
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user != null) {
      AppRoutes.replace(context, AppRoutes.dashboard);
    } else {
      AppRoutes.replace(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://i.ibb.co/FK6Rfqs/admin-bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: isDark
                ? const Color.fromRGBO(0, 0, 0, 0.7)
                : const Color.fromRGBO(255, 255, 255, 0.6),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: "gostore-logo",
                    child: Image.network(
                      "https://i.ibb.co/pdH9PLD/gostore-logo.png",
                      width: 160,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.store,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
