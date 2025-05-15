import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/services/export_service.dart';
import 'package:gostore_partner/widgets/sales_chart_widget.dart';
import 'package:gostore_partner/widgets/fraud_heatmap_widget.dart';
import 'package:gostore_partner/widgets/top_selling_leaderboard.dart';
import 'package:gostore_partner/widgets/live_alert_button.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:intl/intl.dart';
import 'package:gostore_partner/utils/routes.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Admin Analytics", style: AppTextStyle.headingLarge(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: () => ExportService().exportSalesReport(asPdf: true),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: "Export Excel",
            onPressed: () => ExportService().exportSalesReport(asPdf: false),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: "Export Fraud Logs",
            onPressed: () => ExportService().exportFraudLogsCsv(),
          ),
        ],
      ),
      floatingActionButton: LiveAlertButton(
        onPressed: () => AppRoutes.go(context, AppRoutes.fraud),
        showBadge: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateFilter(context),
            const SizedBox(height: AppSpacing.sm),
            _buildRevenueComparisonCards(context),
            const Divider(thickness: 1.2, height: 32),
            Text("📈 Sales Overview", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: 10),
            SalesChartWidget(dateRange: selectedRange),
            const Divider(thickness: 1.2, height: 32),
            Text("🚨 Fraud Heatmap", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: 10),
            const FraudHeatmapWidget(),
            const Divider(thickness: 1.2, height: 32),
            Text("🏆 Top-Selling Products", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: 10),
            const TopSellingLeaderboard(),
            const Divider(thickness: 1.2, height: 32),
            _buildRealtimeSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: AppButtonStyles.secondary,
          icon: const Icon(Icons.date_range),
          label: const Text("Filter by Date"),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 2),
              lastDate: now,
              initialDateRange: selectedRange,
            );
            if (picked != null) {
              setState(() => selectedRange = picked);
            }
          },
        ),
        if (selectedRange != null) ...[
          const SizedBox(width: 12),
          Text(
            "${DateFormat.yMMMd().format(selectedRange!.start)} → ${DateFormat.yMMMd().format(selectedRange!.end)}",
            style: AppTextStyle.caption(context),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 18),
        ]
      ],
    );
  }

  Widget _buildRevenueComparisonCards(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _fetchRevenueComparisons(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final thisWeek = snapshot.data!["thisWeek"]!;
        final lastWeek = snapshot.data!["lastWeek"]!;
        final trend = thisWeek >= lastWeek ? "⬆️" : "⬇️";
        final color = thisWeek >= lastWeek ? Colors.green : Colors.red;

        return Row(
          children: [
            _buildStatCard("This Week", thisWeek, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard("Last Week", lastWeek, Colors.grey),
            const SizedBox(width: 12),
            _buildStatCard("Trend", thisWeek - lastWeek, color, suffix: trend),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, double value, Color color, {String suffix = ""}) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text("₹${value.toStringAsFixed(2)} $suffix", style: AppTextStyle.body(context)),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyle.caption(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, double>> _fetchRevenueComparisons() async {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance.collection("transactions").get();
    double thisWeekTotal = 0.0;
    double lastWeekTotal = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final ts = (data["timestamp"] as Timestamp).toDate();
      final amount = (data["totalAmount"] ?? 0).toDouble();

      if (ts.isAfter(startOfThisWeek)) {
        thisWeekTotal += amount;
      } else if (ts.isAfter(startOfLastWeek) && ts.isBefore(endOfLastWeek)) {
        lastWeekTotal += amount;
      }
    }

    return {
      "thisWeek": thisWeekTotal,
      "lastWeek": lastWeekTotal,
    };
  }

  Widget _buildRealtimeSummary(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("transactions").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final totalTransactions = snapshot.data!.docs.length;
        final totalRevenue = snapshot.data!.docs.fold<double>(0.0, (sum, doc) {
          final d = doc.data() as Map<String, dynamic>;
          return sum + (d["totalAmount"] ?? 0).toDouble();
        });

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: ListTile(
            leading: const Icon(Icons.bar_chart, size: 40, color: Colors.green),
            title: Text("Live Transactions: $totalTransactions", style: AppTextStyle.body(context)),
            subtitle: Text("Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}", style: AppTextStyle.caption(context)),
          ),
        );
      },
    );
  }
}
