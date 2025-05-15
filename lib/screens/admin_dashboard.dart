import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gostore_partner/services/export_service.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📋 Admin Dashboard', style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: AppPaddings.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 Quick Analytics", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: AppSpacing.md),
            _buildLiveSummary(context),
            const SizedBox(height: AppSpacing.md),
            _buildExportButtons(context),
            const SizedBox(height: AppSpacing.md),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.md),
            _buildFraudAlerts(context),
            const SizedBox(height: AppSpacing.lg),
            Text("🛒 Recent Orders", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildOrdersList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSummary(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("transactions").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final totalRevenue = docs.fold<double>(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data["totalAmount"] ?? 0).toDouble();
        });

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            _DashboardCard(label: "Live Sales", value: "₹${totalRevenue.toStringAsFixed(0)}", icon: Icons.currency_rupee),
            _DashboardCard(label: "Orders", value: docs.length.toString(), icon: Icons.receipt_long),
          ],
        );
      },
    );
  }

  Widget _buildExportButtons(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      children: [
        ElevatedButton.icon(
          onPressed: () => ExportService().exportSalesReport(asPdf: true),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Export Sales PDF"),
        ),
        ElevatedButton.icon(
          onPressed: () => ExportService().exportInventoryReport(asPdf: false),
          icon: const Icon(Icons.table_chart),
          label: const Text("Export Inventory Excel"),
        ),
        ElevatedButton.icon(
          onPressed: () => ExportService().exportFraudLogsCsv(),
          icon: const Icon(Icons.warning_amber),
          label: const Text("Export Fraud Logs"),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔒 Store Locked")));
          },
          icon: const Icon(Icons.lock),
          label: const Text("Lock Store"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📦 Add Product Coming Soon")));
          },
          icon: const Icon(Icons.add_box),
          label: const Text("Add Product"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 Alert Sent")));
          },
          icon: const Icon(Icons.campaign),
          label: const Text("Send Alert"),
        ),
      ],
    );
  }

  Widget _buildFraudAlerts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("fraud_logs")
          .where("resolved", isEqualTo: false)
          .orderBy("timestamp", descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final frauds = snapshot.data!.docs;
        if (frauds.isEmpty) {
          return Text("✅ No active fraud alerts", style: AppTextStyle.body(context));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🚨 Recent Fraud Alerts", style: AppTextStyle.headingMedium(context)),
            const SizedBox(height: AppSpacing.sm),
            ...frauds.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final desc = data["description"] ?? "No description";
              final time = (data["timestamp"] as Timestamp?)?.toDate().toLocal().toString().split(' ').first ?? "";
              return ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: Text(desc, style: AppTextStyle.body(context)),
                subtitle: Text("Date: $time", style: AppTextStyle.caption(context)),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("transactions")
          .where("userId", isEqualTo: userId)
          .orderBy("timestamp", descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const Card(
              margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text("Loading...", style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text("No recent orders", style: AppTextStyle.body(context)),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final order = docs[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                leading: const Icon(Icons.shopping_cart),
                title: Text(
                  "Order: ₹${order['totalAmount'] ?? '0'}",
                  style: AppTextStyle.body(context),
                ),
                subtitle: Text(
                  "Method: ${order['method'] ?? 'N/A'}",
                  style: AppTextStyle.caption(context),
                ),
                trailing: Text(
                  (order['timestamp'] as Timestamp?)?.toDate().toString().split(' ').first ?? '',
                  style: AppTextStyle.caption(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - AppSpacing.lg,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.deepPurple),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: AppTextStyle.body(context).copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label, style: AppTextStyle.caption(context)),
            ],
          ),
        ),
      ),
    );
  }
}
