import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class FraudStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const FraudStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, radius: 8),
            const SizedBox(width: AppSpacing.sm),
            Text("$label — $count", style: AppTextStyle.body(context)),
          ],
        ),
      ),
    );
  }
}
