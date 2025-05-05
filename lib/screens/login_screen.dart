import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gostore_partner/services/auth_service.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';
import 'package:gostore_partner/screens/qr_scanner_screen.dart';
import 'package:gostore_partner/screens/admin_invite_signup_screen.dart';
import 'package:gostore_partner/screens/biometric_login_screen.dart';
import 'package:gostore_partner/utils/ui_config.dart';

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
  String? _verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> _loginWithEmail() async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (credential.user != null) _redirectToAdminDashboard();
    } catch (e) {
      _showError("Email login failed: $e");
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
        verificationFailed: (e) => _showError("OTP failed: ${e.message}"),
        codeSent: (vid, _) {
          _verificationId = vid;
          _showMessage("OTP sent to ${phoneController.text}");
        },
        codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
      );
    } catch (e) {
      _showError("Failed to send OTP: $e");
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) {
      _showError("OTP not sent yet.");
      return;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) _redirectToAdminDashboard();
    } catch (e) {
      _showError("Invalid OTP: $e");
    }
  }

  Future<void> _loginWithGoogle() async {
    final user = await AuthService().signInWithGoogle(context);
    if (user != null) _redirectToAdminDashboard();
  }

  void _redirectToAdminDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  void _scanAdminInviteQR() async {
    final scannedToken = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen(forAdminInvite: true)),
    );
    if (scannedToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminInviteSignupScreen(inviteToken: scannedToken),
        ),
      );
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showError(String err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: "https://i.ibb.co/pdH9PLD/gostore-logo.png",
                    width: width * 0.4,
                  ),
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
                      children: [
                        // Email Login
                        Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: "Email"),
                            ),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: "Password"),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: AppButtonStyles.primary,
                              icon: const Icon(Icons.login),
                              label: const Text("Login"),
                              onPressed: _loginWithEmail,
                            ),
                          ],
                        ),
                        // Phone Login
                        Column(
                          children: [
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: "Phone Number"),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: AppButtonStyles.primary,
                              icon: const Icon(Icons.sms),
                              label: const Text("Send OTP"),
                              onPressed: _sendOTP,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: otpController,
                              decoration: const InputDecoration(labelText: "Enter OTP"),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: AppButtonStyles.primary,
                              icon: const Icon(Icons.verified),
                              label: const Text("Verify OTP"),
                              onPressed: _verifyOTP,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  ElevatedButton.icon(
                    style: AppButtonStyles.primary,
                    icon: CachedNetworkImage(
                      imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/768px-Google_%22G%22_Logo.svg.png",
                      width: width * 0.06,
                    ),
                    label: const Text("Sign in with Google"),
                    onPressed: _loginWithGoogle,
                  ),
                  SizedBox(height: height * 0.02),
                  ElevatedButton.icon(
                    style: AppButtonStyles.primary,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Biometric Login"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BiometricLoginScreen()),
                      );
                    },
                  ),
                  SizedBox(height: height * 0.02),
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
      ),
    );
  }
}
