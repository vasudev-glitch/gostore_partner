import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Name"),
            subtitle: Text(user?.displayName ?? "Not available"),
          ),
          ListTile(
            title: const Text("Email"),
            subtitle: Text(user?.email ?? "Not available"),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Enable Fraud Alerts"),
            value: true,
            onChanged: (val) {
              // Future: Save toggle to Firestore for alert preferences
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
