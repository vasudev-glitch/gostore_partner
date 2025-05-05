import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> purchaseHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchaseHistory();
  }

  /// Fetch Purchase History
  void _fetchPurchaseHistory() {
    final userId = user?.uid ?? '';
    if (userId.isEmpty) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("purchase_history")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        purchaseHistory = snapshot.docs.map((doc) => doc.data()).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("👤 Profile", style: AppTextStyle.headingLarge(context))),
      body: ListView(
        padding: AppPaddings.screen,
        children: [
          Text("📜 Purchase History", style: AppTextStyle.headingLarge(context)),
          const SizedBox(height: 10),
          if (purchaseHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No purchases yet.", style: AppTextStyle.body(context)),
              ),
            )
          else
            ...purchaseHistory.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(item["name"] ?? "Item", style: AppTextStyle.body(context)),
                  subtitle: Text("₹${item["price"] ?? "0.00"}", style: AppTextStyle.caption(context)),
                ),
              );
            }),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/payment-test");
              },
              style: AppButtonStyles.primary,
              child: const Text("Test Payments"),
            ),
          ),
        ],
      ),
    );
  }
}
