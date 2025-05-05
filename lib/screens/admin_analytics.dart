import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/widgets/sales_chart_widget.dart';
import 'package:gostore_partner/widgets/fraud_heatmap_widget.dart';
import 'package:gostore_partner/widgets/top_selling_leaderboard.dart';
import 'package:gostore_partner/widgets/live_alert_button.dart';
import 'package:gostore_partner/utils/ui_config.dart'; // Centralized UI config

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Admin Analytics", style: AppTextStyle.headingLarge(context)),
      ),
      floatingActionButton: LiveAlertButton(
        onPressed: () {
          Navigator.pushNamed(context, "/fraud-logs");
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📈 Sales Overview", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: 10),
            const SalesChartWidget(),
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

  Widget _buildRealtimeSummary(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("transactions").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalTransactions = snapshot.data!.docs.length;
        final totalRevenue = snapshot.data!.docs.fold<double>(
          0.0,
              (sum, doc) {
            final amount = doc["totalAmount"];
            return sum + (amount is num ? amount.toDouble() : 0.0);
          },
        );

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: ListTile(
            leading: const Icon(Icons.bar_chart, size: 40, color: Colors.green),
            title: Text(
              "Live Transactions: $totalTransactions",
              style: AppTextStyle.body(context),
            ),
            subtitle: Text(
              "Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}",
              style: AppTextStyle.caption(context),
            ),
          ),
        );
      },
    );
  }
}
