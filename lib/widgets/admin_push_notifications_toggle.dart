import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPushNotificationsToggle extends StatefulWidget {
  const AdminPushNotificationsToggle({super.key});

  @override
  State<AdminPushNotificationsToggle> createState() => _AdminPushNotificationsToggleState();
}

class _AdminPushNotificationsToggleState extends State<AdminPushNotificationsToggle> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  void _loadNotificationStatus() {
    _firestore.collection("settings").doc("push_notifications").get().then((doc) {
      if (doc.exists) {
        setState(() {
          notificationsEnabled = doc.data()?["enabled"] ?? true;
        });
      }
    });
  }

  Future<void> _updateNotificationStatus(bool value) async {
    await _firestore.collection("settings").doc("push_notifications").set({"enabled": value});
    setState(() {
      notificationsEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value ? "🔔 Push Notifications Enabled" : "🔕 Push Notifications Disabled"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("🔔 Admin Push Notifications"),
      subtitle: const Text("Enable/Disable fraud & store alerts"),
      value: notificationsEnabled,
      onChanged: _updateNotificationStatus,
    );
  }
}
