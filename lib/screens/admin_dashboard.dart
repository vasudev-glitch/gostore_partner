import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gostore_partner/widgets/sales_chart_widget.dart';
import 'package:gostore_partner/widgets/fraud_heatmap_widget.dart';
import 'package:gostore_partner/widgets/top_selling_leaderboard.dart';
import 'package:gostore_partner/services/export_service.dart';
import 'package:gostore_partner/widgets/admin_group_chat.dart';
import 'package:gostore_partner/widgets/add_admin_invite_button.dart';
import 'package:gostore_partner/widgets/admin_push_notifications_toggle.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🚨 ${message.notification!.title}: ${message.notification!.body}"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = _auth.currentUser?.displayName ?? "Admin";

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName 👋", style: AppTextStyle.headingLarge(context)),
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SalesChartWidget(),
            const SizedBox(height: 20),
            const FraudHeatmapWidget(),
            const SizedBox(height: 20),
            const TopSellingLeaderboard(),
            const Divider(thickness: 1.2),
            const AdminPushNotificationsToggle(),
            const Divider(thickness: 1.2),
            _buildExportSection(),
            const Divider(thickness: 1.2),
            Text("➕ Add New Admin", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: 10),
            const AddAdminInviteButton(),
            const Divider(thickness: 1.2),
            _buildGroupChatSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📥 Export Reports", style: AppTextStyle.headingLarge(context)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: AppButtonStyles.primary,
              onPressed: () => ExportService().exportSalesReport(asPdf: true),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Sales PDF"),
            ),
            ElevatedButton.icon(
              style: AppButtonStyles.primary,
              onPressed: () => ExportService().exportInventoryReport(asPdf: true),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Inventory PDF"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: AppButtonStyles.primary,
              onPressed: () => ExportService().exportSalesReport(asPdf: false),
              icon: const Icon(Icons.table_chart),
              label: const Text("Sales CSV"),
            ),
            ElevatedButton.icon(
              style: AppButtonStyles.primary,
              onPressed: () => ExportService().exportInventoryReport(asPdf: false),
              icon: const Icon(Icons.table_chart),
              label: const Text("Inventory CSV"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("💬 Admin Group Chat", style: AppTextStyle.headingLarge(context)),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            style: AppButtonStyles.large,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminGroupChat()),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text("Open Group Chat"),
          ),
        ),
      ],
    );
  }
}
