import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:intl/intl.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? _generatedToken;

  Future<void> _generateInviteToken() async {
    final token = DateTime.now().millisecondsSinceEpoch.toString() + "_" + UniqueKey().toString();
    final docRef = await FirebaseFirestore.instance.collection('admin_invites').add({
      'inviteToken': token,
      'used': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _generatedToken = token;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Invite token generated")),
    );
  }

  Future<void> _updateRole(String uid, String newRole) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({'role': newRole});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🔄 Role updated to $newRole")),
    );
  }

  Widget _buildAdminList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").where("role", isGreaterThan: "").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final admins = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: admins.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'];
            final uid = doc.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: Text(data['name'] ?? "Unnamed", style: AppTextStyle.body(context)),
                subtitle: Text(data['email'] ?? "-", style: AppTextStyle.caption(context)),
                trailing: DropdownButton<String>(
                  value: role,
                  onChanged: (value) {
                    if (value != null) _updateRole(uid, value);
                  },
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text("Viewer")),
                    DropdownMenuItem(value: 'editor', child: Text("Editor")),
                    DropdownMenuItem(value: 'superadmin', child: Text("Super Admin")),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAuditLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("admin_logs").orderBy("timestamp", descending: true).limit(10).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final logs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: logs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final action = data['action'] ?? "Unknown Action";
            final admin = data['adminName'] ?? "Unknown Admin";
            final time = (data['timestamp'] as Timestamp?)?.toDate();
            final formattedTime = time != null ? DateFormat.yMd().add_jm().format(time) : "Unknown";

            return ListTile(
              leading: const Icon(Icons.history),
              title: Text("$admin • $action", style: AppTextStyle.body(context)),
              subtitle: Text(formattedTime, style: AppTextStyle.caption(context)),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🛠 Admin Panel", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋 Welcome, Admin", style: AppTextStyle.headingMedium(context)),
            const SizedBox(height: AppSpacing.md),

            ElevatedButton.icon(
              onPressed: _generateInviteToken,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Generate Invite Token"),
              style: AppButtonStyles.primary,
            ),
            if (_generatedToken != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SelectableText("🔗 Token: $_generatedToken", style: AppTextStyle.caption(context)),
            ],

            const Divider(height: 40),
            Text("🧑‍💼 Manage Roles", style: AppTextStyle.headingMedium(context)),
            const SizedBox(height: AppSpacing.sm),
            _buildAdminList(),

            const Divider(height: 40),
            Text("📋 Audit Logs", style: AppTextStyle.headingMedium(context)),
            const SizedBox(height: AppSpacing.sm),
            _buildAuditLogs(),
          ],
        ),
      ),
    );
  }
}
