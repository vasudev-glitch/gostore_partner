import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:gostore_partner/services/export_service.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool darkTheme = true;
  bool biometricLock = false;
  String selectedLanguage = 'English';
  String? name;
  String? email;

  final _auth = FirebaseAuth.instance;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
    _loadProfile();
    _loadPreferences();
    _maybeRequireBiometric();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        name = doc.data()?['name'] ?? 'Not available';
        email = doc.data()?['email'] ?? 'Not available';
      });
    }
  }

  Future<void> _loadThemeSetting() async {
    final doc = await FirebaseFirestore.instance.collection('themes').doc('default').get();
    if (doc.exists && doc.data()?['brightness'] == 'light') {
      setState(() => darkTheme = false);
    }
  }

  Future<void> _loadPreferences() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('admin_preferences').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        biometricLock = data['biometricLock'] ?? false;
        selectedLanguage = data['language'] ?? 'English';
      });
    }
  }

  Future<void> _maybeRequireBiometric() async {
    if (!biometricLock) return;
    final available = await _localAuth.canCheckBiometrics;
    if (!available) return;

    final authenticated = await _localAuth.authenticate(
      localizedReason: "Please authenticate to access admin settings",
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (!authenticated && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _savePreferences() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('admin_preferences').doc(uid).set({
      'biometricLock': biometricLock,
      'language': selectedLanguage,
    }, SetOptions(merge: true));
  }

  Future<void> _toggleTheme(bool isDark) async {
    setState(() => darkTheme = isDark);
    await FirebaseFirestore.instance.collection('themes').doc('default').update({
      'brightness': isDark ? 'dark' : 'light',
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔄 Theme updated to ${isDark ? 'Dark' : 'Light'}"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _changeLanguage(String? newLang) {
    if (newLang != null) {
      setState(() => selectedLanguage = newLang);
      _savePreferences();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🌐 Language changed to $newLang"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚙️ Admin Settings", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppPaddings.screen,
        children: [
          Text("👤 Profile", style: AppTextStyle.body(context)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Column(
              children: [
                ListTile(
                  title: const Text("Name"),
                  subtitle: Text(name ?? "Loading..."),
                ),
                ListTile(
                  title: const Text("Email"),
                  subtitle: Text(email ?? "Loading..."),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text("🧩 Preferences", style: AppTextStyle.body(context)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Switch Theme"),
                  value: darkTheme,
                  onChanged: _toggleTheme,
                ),
                SwitchListTile(
                  title: const Text("Biometric Lock"),
                  value: biometricLock,
                  onChanged: (val) {
                    setState(() => biometricLock = val);
                    _savePreferences();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("App Language"),
                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text("English")),
                      DropdownMenuItem(value: 'Hindi', child: Text("Hindi")),
                      DropdownMenuItem(value: 'Tamil', child: Text("Tamil")),
                    ],
                    onChanged: _changeLanguage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text("📤 Export Options", style: AppTextStyle.body(context)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.deepOrange),
                  title: const Text("Export Sales as PDF"),
                  onTap: () => ExportService().exportSalesReport(asPdf: true),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.indigo),
                  title: const Text("Export Sales as Excel"),
                  onTap: () => ExportService().exportSalesReport(asPdf: false),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.green),
                  title: const Text("Export Inventory Report"),
                  onTap: () => ExportService().exportInventoryReport(asPdf: false),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: const Text("Export Fraud Logs"),
                  onTap: () => ExportService().exportFraudLogsCsv(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }
}
