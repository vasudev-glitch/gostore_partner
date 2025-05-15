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

  Widget _buildProfileInfo(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Admin Info", style: AppTextStyle.body(context)),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: Text(user?.email ?? "Email unavailable", style: AppTextStyle.body(context)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(user?.displayName ?? "Anonymous", style: AppTextStyle.body(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseHistory(BuildContext context) {
    if (purchaseHistory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
              const SizedBox(height: AppSpacing.sm),
              Text("No purchase history yet.", style: AppTextStyle.caption(context)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchaseHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = purchaseHistory[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(item["name"] ?? "Item", style: AppTextStyle.body(context)),
            subtitle: Text(
              "₹${item["price"] ?? "0.00"}",
              style: AppTextStyle.caption(context),
            ),
            trailing: item["timestamp"] != null
                ? Text(
              (item["timestamp"] as Timestamp).toDate().toString().split(' ').first,
              style: AppTextStyle.caption(context),
            )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("👤 Profile", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppPaddings.screen,
        children: [
          _buildProfileInfo(context),
          const SizedBox(height: AppSpacing.lg),
          Text("🧾 Purchase History", style: AppTextStyle.headingLarge(context)),
          const SizedBox(height: AppSpacing.md),
          _buildPurchaseHistory(context),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, "/payment-test"),
              icon: const Icon(Icons.credit_score),
              label: const Text("Test Payments"),
              style: AppButtonStyles.primary,
            ),
          ),
        ],
      ),
    );
  }
}
