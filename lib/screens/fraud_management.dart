import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class FraudManagementScreen extends StatefulWidget {
  const FraudManagementScreen({super.key});

  @override
  FraudManagementScreenState createState() => FraudManagementScreenState();
}

class FraudManagementScreenState extends State<FraudManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Resolve Fraud Case
  void _resolveFraud(String fraudId) {
    _firestore.collection("fraud_logs").doc(fraudId).update({"resolved": true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Fraud Case Resolved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🚨 Fraud Cases", style: AppTextStyle.headingLarge(context)),
      ),
      body: Padding(
        padding: AppPaddings.screen,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("fraud_logs")
              .where("resolved", isEqualTo: false)
              .orderBy("flaggedAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final cases = snapshot.data!.docs;
            if (cases.isEmpty) {
              return Center(
                child: Text("🎉 No unresolved fraud cases", style: AppTextStyle.body(context)),
              );
            }

            return ListView.builder(
              itemCount: cases.length,
              itemBuilder: (context, index) {
                final doc = cases[index];
                final data = doc.data() as Map<String, dynamic>;

                final issue = data["issue"] ?? "No description";
                final flaggedAt = (data["flaggedAt"] as Timestamp?)?.toDate();

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(issue, style: AppTextStyle.body(context)),
                    subtitle: Text(
                      flaggedAt != null
                          ? "Flagged: ${flaggedAt.toLocal()}"
                          : "Date unavailable",
                      style: AppTextStyle.caption(context),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _resolveFraud(doc.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
