import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:gostore_partner/services/export_service.dart';
import 'package:gostore_partner/widgets/fraud_card.dart';
import 'package:gostore_partner/widgets/fraud_stat_card.dart';
import 'package:gostore_partner/widgets/fraud_heatmap_widget.dart';
import 'package:gostore_partner/widgets/fraud_filters_bar.dart';

class FraudManagementScreen extends StatefulWidget {
  const FraudManagementScreen({super.key});

  @override
  State<FraudManagementScreen> createState() => _FraudManagementScreenState();
}

class _FraudManagementScreenState extends State<FraudManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> adminList = [];

  DateTimeRange? _selectedDateRange;
  String? _selectedSeverity;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    final snapshot = await _firestore.collection("users").where("role", isEqualTo: "admin").get();
    setState(() {
      adminList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "uid": doc.id,
          "name": data["name"]?.toString() ?? "Unnamed Admin",
        };
      }).toList();
    });
  }

  Future<void> _assignAdmin(String fraudId, String? adminUid) async {
    final selectedAdmin = adminList.firstWhere((a) => a["uid"] == adminUid, orElse: () => {});
    await _firestore.collection("fraud_logs").doc(fraudId).update({
      "assignedTo": selectedAdmin["name"] ?? "Unassigned",
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("👤 Assigned to ${selectedAdmin['name']}")),
    );
  }

  Future<void> _resolveFraud(String fraudId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resolve Fraud"),
        content: const Text("Mark this fraud case as resolved?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Resolve")),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection("fraud_logs").doc(fraudId).update({
        "resolved": true,
        "resolvedAt": FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Fraud case resolved")),
      );
    }
  }

  Widget _buildUnresolved() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("fraud_logs")
          .where("resolved", isEqualTo: false)
          .orderBy("flaggedAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final ts = (data['flaggedAt'] as Timestamp?)?.toDate();
          final matchesDate = _selectedDateRange == null ||
              (ts != null &&
                  ts.isAfter(_selectedDateRange!.start) &&
                  ts.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

          final matchesSeverity = _selectedSeverity == null || data['severity'] == _selectedSeverity;

          return matchesDate && matchesSeverity;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FraudFiltersBar(
                selectedDateRange: _selectedDateRange,
                selectedSeverity: _selectedSeverity,
                onDateChange: (range) => setState(() => _selectedDateRange = range),
                onSeverityChange: (level) => setState(() => _selectedSeverity = level),
              ),
            ),
            Expanded(
              child: docs.isEmpty
                  ? const Center(child: Text("🎉 No unresolved fraud cases"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return FraudCard(
                    data: data,
                    showResolve: true,
                    adminList: adminList,
                    onResolve: () => _resolveFraud(doc.id),
                    onAssign: (uid) => _assignAdmin(doc.id, uid),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResolvedHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("fraud_logs")
          .where("resolved", isEqualTo: true)
          .orderBy("resolvedAt", descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return FraudCard(
              data: data,
              adminList: adminList,
            );
          },
        );
      },
    );
  }

  Widget _buildInsights() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection("fraud_logs").get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final all = snapshot.data!.docs;
        final unresolved = all.where((d) => !(d['resolved'] ?? false)).length;
        final resolved = all.where((d) => d['resolved'] == true).length;
        final today = all.where((d) {
          final time = (d['flaggedAt'] as Timestamp?)?.toDate();
          return time != null && DateTime.now().difference(time).inDays == 0;
        }).length;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            FraudStatCard(label: "📊 Total Fraud Cases", count: all.length, color: Colors.black),
            FraudStatCard(label: "🟡 Unresolved Cases", count: unresolved, color: Colors.orange),
            FraudStatCard(label: "✅ Resolved Cases", count: resolved, color: Colors.green),
            FraudStatCard(label: "📅 Flagged Today", count: today, color: Colors.blue),
            const FraudHeatmapWidget(),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => ExportService().exportFraudLogsCsv(),
              icon: const Icon(Icons.file_download),
              label: const Text("Export All Logs"),
              style: AppButtonStyles.secondary,
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🚨 Fraud Management", style: AppTextStyle.headingLarge(context)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "🟡 Unresolved"),
            Tab(text: "✅ Resolved"),
            Tab(text: "📊 Insights"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnresolved(),
          _buildResolvedHistory(),
          _buildInsights(),
        ],
      ),
    );
  }
}
