import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';
import 'package:gostore_partner/screens/qr_scanner_screen.dart';
import 'package:gostore_partner/screens/admin_invite_signup_screen.dart';
import 'package:gostore_partner/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _biometricAuth = LocalAuthentication();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? _verificationId;
  bool _isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : null),
    );
  }

  void _redirectToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
  }

  Future<void> _loginWithEmail() async {
    setState(() => _isLoading = true);
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (userCred.user != null) _redirectToDashboard();
    } catch (e) {
      _showMessage("Login failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOTP() async {
    setState(() => _isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        verificationCompleted: (cred) async {
          await _auth.signInWithCredential(cred);
          _redirectToDashboard();
        },
        verificationFailed: (e) => _showMessage("OTP failed: ${e.message}", isError: true),
        codeSent: (vid, _) {
          _verificationId = vid;
          _showMessage("OTP sent to ${phoneController.text}");
        },
        codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
      );
    } catch (e) {
      _showMessage("Failed to send OTP: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return _showMessage("OTP not sent yet", isError: true);
    setState(() => _isLoading = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );
      final userCred = await _auth.signInWithCredential(cred);
      if (userCred.user != null) _redirectToDashboard();
    } catch (e) {
      _showMessage("Invalid OTP: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    final user = await AuthService().signInWithGoogle(context);
    if (user != null) _redirectToDashboard();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loginWithBiometrics() async {
    try {
      final canCheck = await _biometricAuth.canCheckBiometrics;
      if (!canCheck) return _showMessage("Biometric not available", isError: true);
      final auth = await _biometricAuth.authenticate(
        localizedReason: 'Authenticate to access admin panel',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (auth) {
        _redirectToDashboard();
      } else {
        _showMessage("Biometric failed", isError: true);
      }
    } catch (e) {
      _showMessage("Biometric error: $e", isError: true);
    }
  }

  Future<void> _scanInviteQR() async {
    final token = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen(forAdminInvite: true)),
    );
    if (token != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminInviteSignupScreen(inviteToken: token)),
      );
    }
  }

  Widget _buildEmailTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: emailController,
        style: AppTextStyle.body(context),
        decoration: const InputDecoration(labelText: "Email", filled: true),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextField(
        controller: passwordController,
        obscureText: true,
        style: AppTextStyle.body(context),
        decoration: const InputDecoration(labelText: "Password", filled: true),
      ),
      const SizedBox(height: AppSpacing.md),
      ElevatedButton.icon(
        onPressed: _isLoading ? null : _loginWithEmail,
        icon: const Icon(Icons.login),
        label: const Text("Login"),
        style: AppButtonStyles.primary,
      ),
    ],
  );

  Widget _buildPhoneTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        style: AppTextStyle.body(context),
        decoration: const InputDecoration(labelText: "Phone", filled: true),
      ),
      const SizedBox(height: AppSpacing.sm),
      ElevatedButton.icon(
        onPressed: _isLoading ? null : _sendOTP,
        icon: const Icon(Icons.sms),
        label: const Text("Send OTP"),
        style: AppButtonStyles.primary,
      ),
      const SizedBox(height: AppSpacing.sm),
      TextField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: AppTextStyle.body(context),
        decoration: const InputDecoration(labelText: "Enter OTP", filled: true),
      ),
      const SizedBox(height: AppSpacing.sm),
      ElevatedButton.icon(
        onPressed: _isLoading ? null : _verifyOTP,
        icon: const Icon(Icons.verified),
        label: const Text("Verify"),
        style: AppButtonStyles.primary,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: Image(
                image: NetworkImage("https://images.unsplash.com/photo-1607083209444-33d25cc1fe2e"),
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              padding: AppPaddings.screen.copyWith(top: 40, bottom: 60),
              child: Column(
                children: [
                  CachedNetworkImage(imageUrl: "https://i.ibb.co/pdH9PLD/gostore-logo.png", width: 130),
                  const SizedBox(height: AppSpacing.lg),
                  Text("Admin Login", style: AppTextStyle.headingLarge(context).copyWith(color: Colors.white)),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          tabs: const [
                            Tab(text: "Email Login"),
                            Tab(text: "Phone Login"),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            controller: _tabController,
                            children: [_buildEmailTab(), _buildPhoneTab()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: CachedNetworkImage(
                      imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/768px-Google_%22G%22_Logo.svg.png",
                      width: 20,
                    ),
                    label: const Text("Continue with Google"),
                    style: AppButtonStyles.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Login with Biometrics"),
                    onPressed: _isLoading ? null : _loginWithBiometrics,
                    style: AppButtonStyles.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Sign up with Invite QR"),
                    onPressed: _scanInviteQR,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
