import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class FraudHeatmapWidget extends StatefulWidget {
  const FraudHeatmapWidget({super.key});

  @override
  State<FraudHeatmapWidget> createState() => _FraudHeatmapWidgetState();
}

class _FraudHeatmapWidgetState extends State<FraudHeatmapWidget> {
  final Map<int, int> fraudCountPerHour = {};

  @override
  void initState() {
    super.initState();
    _fetchFraudData();
  }

  void _fetchFraudData() {
    final DateTime last24Hours = DateTime.now().subtract(const Duration(hours: 24));

    FirebaseFirestore.instance
        .collection("fraud_logs")
        .where("flaggedAt", isGreaterThan: last24Hours)
        .snapshots()
        .listen((snapshot) {
      final Map<int, int> counts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data["flaggedAt"] as Timestamp).toDate();
        final hour = timestamp.hour;
        counts[hour] = (counts[hour] ?? 0) + 1;
      }
      setState(() {
        fraudCountPerHour.clear();
        fraudCountPerHour.addAll(counts);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return fraudCountPerHour.isEmpty
        ? const Center(child: Text("No fraud attempts in the last 24 hours"))
        : Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 Hourly Heatmap", style: AppTextStyle.headingLarge(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(24, (hour) {
                final count = fraudCountPerHour[hour] ?? 0;
                final colorIntensity = (count * 40).clamp(0, 255);
                return Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 0, 0).withAlpha(colorIntensity),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "$hour:00",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
