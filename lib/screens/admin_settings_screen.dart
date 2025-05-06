import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool fraudAlertsEnabled = true;
  bool darkTheme = true;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  void _loadThemeSetting() async {
    final doc = await FirebaseFirestore.instance.collection('themes').doc('default').get();
    if (doc.exists && doc.data()?['brightness'] == 'light') {
      setState(() => darkTheme = false);
    }
  }

  Future<void> _toggleTheme(bool isDark) async {
    setState(() => darkTheme = isDark);
    await FirebaseFirestore.instance.collection('themes').doc('default').update({
      'brightness': isDark ? 'dark' : 'light',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🔄 Theme updated to ${isDark ? 'Dark' : 'Light'}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("👤 Profile", style: Theme.of(context).textTheme.titleMedium),
          ListTile(title: const Text("Name"), subtitle: Text(user?.displayName ?? "Not available")),
          ListTile(title: const Text("Email"), subtitle: Text(user?.email ?? "Not available")),
          const Divider(),
          SwitchListTile(
            title: const Text("Enable Fraud Alerts"),
            value: fraudAlertsEnabled,
            onChanged: (val) => setState(() => fraudAlertsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Switch Theme"),
            value: darkTheme,
            onChanged: _toggleTheme,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Export as PDF"),
            onTap: () {
              // TODO: Hook to PDF export logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text("Export as Excel"),
            onTap: () {
              // TODO: Hook to Excel export logic
            },
          ),
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
