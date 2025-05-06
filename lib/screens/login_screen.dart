import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gostore_partner/services/auth_service.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';
import 'package:gostore_partner/screens/qr_scanner_screen.dart';
import 'package:gostore_partner/screens/admin_invite_signup_screen.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:local_auth/local_auth.dart'; // ✅ From your local override
import 'package:local_auth/src/types/authentication_options.dart'; // ✅ From your local override

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _biometricAuth = LocalAuthentication();

  String? _verificationId;

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

  void _redirectToAdminDashboard() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  Future<void> _loginWithEmail() async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (credential.user != null) _redirectToAdminDashboard();
    } catch (e) {
      _showMessage("Email login failed: $e", isError: true);
    }
  }

  Future<void> _sendOTP() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        verificationCompleted: (cred) async {
          await _auth.signInWithCredential(cred);
          _redirectToAdminDashboard();
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
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return _showMessage("OTP not sent yet.", isError: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );
      final user = await _auth.signInWithCredential(credential);
      if (user.user != null) _redirectToAdminDashboard();
    } catch (e) {
      _showMessage("Invalid OTP: $e", isError: true);
    }
  }

  Future<void> _loginWithGoogle() async {
    final user = await AuthService().signInWithGoogle(context);
    if (user != null) _redirectToAdminDashboard();
  }

  Future<void> _loginWithBiometrics() async {
    try {
      final canCheck = await _biometricAuth.canCheckBiometrics;
      if (!canCheck) return _showMessage("Biometric not available", isError: true);

      final authenticated = await _biometricAuth.authenticate(
        localizedReason: 'Authenticate to access Admin Dashboard',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _redirectToAdminDashboard();
      } else {
        _showMessage("Biometric authentication failed", isError: true);
      }
    } catch (e) {
      _showMessage("Biometric error: $e", isError: true);
    }
  }

  Future<void> _scanAdminInviteQR() async {
    final scannedToken = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen(forAdminInvite: true)),
    );
    if (scannedToken != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminInviteSignupScreen(inviteToken: scannedToken)),
      );
    }
  }

  Widget _buildEmailLoginTab() => Column(
    children: [
      TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
      TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loginWithEmail,
        icon: const Icon(Icons.login),
        label: const Text("Login"),
        style: AppButtonStyles.primary,
      ),
    ],
  );

  Widget _buildPhoneLoginTab() => Column(
    children: [
      TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: _sendOTP,
        icon: const Icon(Icons.sms),
        label: const Text("Send OTP"),
        style: AppButtonStyles.primary,
      ),
      const SizedBox(height: 10),
      TextField(controller: otpController, decoration: const InputDecoration(labelText: "Enter OTP")),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: _verifyOTP,
        icon: const Icon(Icons.verified),
        label: const Text("Verify OTP"),
        style: AppButtonStyles.primary,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1607083209444-33d25cc1fe2e"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              children: [
                CachedNetworkImage(imageUrl: "https://i.ibb.co/pdH9PLD/gostore-logo.png", width: width * 0.4),
                SizedBox(height: height * 0.03),
                Text(
                  "Welcome Admin",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: const [
                      Tab(text: "Email Login"),
                      Tab(text: "Phone Login"),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.38,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildEmailLoginTab(), _buildPhoneLoginTab()],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: CachedNetworkImage(
                    imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/768px-Google_%22G%22_Logo.svg.png",
                    width: width * 0.06,
                  ),
                  label: const Text("Sign in with Google"),
                  onPressed: _loginWithGoogle,
                  style: AppButtonStyles.primary,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Login with Biometrics"),
                  onPressed: _loginWithBiometrics,
                  style: AppButtonStyles.primary,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text("Sign up via Admin Invite QR"),
                  onPressed: _scanAdminInviteQR,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
