import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // ✅ FIXED

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _setUserRoleIfNew(user);
        return user;
      }
      return null;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Google sign-in failed: ${e.toString()}")));
      return null;
    }
  }

  Future<void> _setUserRoleIfNew(User user) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      final usersCount = await FirebaseFirestore.instance.collection("users").get();
      final assignedRole = usersCount.docs.isEmpty ? "admin" : "client";

      await userRef.set({
        "name": user.displayName ?? "New User",
        "email": user.email ?? "",
        "phone": user.phoneNumber ?? "",
        "role": assignedRole,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }
}
