import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class StoreControlsScreen extends StatefulWidget {
  const StoreControlsScreen({super.key});

  @override
  StoreControlsScreenState createState() => StoreControlsScreenState();
}

class StoreControlsScreenState extends State<StoreControlsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _toggleStoreAccess(bool isOpen) {
    _firestore
        .collection("store_settings")
        .doc("access_control")
        .set({"isOpen": isOpen});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Store is now ${isOpen ? 'OPEN' : 'CLOSED'}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🔧 Store Controls", style: AppTextStyle.headingLarge(context)),
      ),
      body: Padding(
        padding: AppPaddings.screen,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _toggleStoreAccess(false),
                icon: const Icon(Icons.lock),
                label: const Text("🚪 Close Store"),
                style: AppButtonStyles.primary,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _toggleStoreAccess(true),
                icon: const Icon(Icons.lock_open),
                label: const Text("✅ Reopen Store"),
                style: AppButtonStyles.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
