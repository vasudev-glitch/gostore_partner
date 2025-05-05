import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> sendOTP(BuildContext context, String phoneNumber) async {
    final messenger = ScaffoldMessenger.of(context);
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text("Auto-verification failed: $e")));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        messenger.showSnackBar(SnackBar(content: Text("OTP failed: ${e.message}")));
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        messenger.showSnackBar(const SnackBar(content: Text("OTP sent!")));
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOTP(BuildContext context, String otpCode) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_verificationId == null) {
      messenger.showSnackBar(const SnackBar(content: Text("No verification ID found.")));
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Invalid OTP: ${e.toString()}")));
    }
  }
}
