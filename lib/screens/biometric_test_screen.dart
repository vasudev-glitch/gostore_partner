import 'package:flutter/material.dart';
import 'package:gostore_partner/local_plugins/local_auth/local_auth.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  String _status = "Waiting for biometric authentication...";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startBiometricAuth();
  }

  Future<void> _startBiometricAuth() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        setState(() {
          _status = "Biometric authentication not available.";
          _loading = false;
        });
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access Admin Dashboard',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        setState(() => _status = "Authentication successful ✅");
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        setState(() {
          _status = "Authentication failed.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error during authentication: $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Padding(
          padding: AppPaddings.screen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: AppSize.blockWidth(context) * 20, color: Colors.tealAccent.shade100),
              const SizedBox(height: 30),
              if (_loading)
                const CircularProgressIndicator(color: Colors.tealAccent)
              else
                ElevatedButton.icon(
                  onPressed: _startBiometricAuth,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: AppButtonStyles.primary.copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.tealAccent.shade100),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: AppTextStyle.body(context).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
