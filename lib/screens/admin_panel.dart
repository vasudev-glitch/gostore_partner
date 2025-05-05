import 'package:flutter/material.dart';
import 'package:gostore_partner/screens/admin_analytics.dart';
import 'package:gostore_partner/screens/inventory_management.dart';
import 'package:gostore_partner/screens/fraud_management.dart';
import 'package:gostore_partner/screens/store_controls.dart';
import 'package:gostore_partner/utils/ui_config.dart'; // ✅ UI configuration

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🛠️ Admin Panel", style: AppTextStyle.headingLarge(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildAdminTile(
            context,
            "📦 Inventory Management",
            Icons.inventory,
            const InventoryManagementScreen(),
          ),
          _buildAdminTile(
            context,
            "📊 Sales & Reports",
            Icons.bar_chart,
            const AdminAnalytics(),
          ),
          _buildAdminTile(
            context,
            "🚨 Fraud Cases",
            Icons.report,
            const FraudManagementScreen(),
          ),
          _buildAdminTile(
            context,
            "🔧 Store Controls",
            Icons.settings,
            const StoreControlsScreen(),
          ),
        ],
      ),
    );
  }

  /// 🔁 Reusable Card Tile
  Widget _buildAdminTile(
      BuildContext context,
      String title,
      IconData icon,
      Widget screen,
      ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(title, style: AppTextStyle.body(context)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
      ),
    );
  }
}
