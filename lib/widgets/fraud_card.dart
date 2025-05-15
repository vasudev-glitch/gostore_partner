import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'admin_dropdown.dart';

class FraudCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool showResolve;
  final VoidCallback? onResolve;
  final ValueChanged<String?>? onAssign;
  final List<Map<String, String>>? adminList;

  const FraudCard({
    super.key,
    required this.data,
    this.showResolve = false,
    this.onResolve,
    this.onAssign,
    this.adminList,
  });

  @override
  Widget build(BuildContext context) {
    final issue = data['issue'] ?? 'No description';
    final flaggedAt = data['flaggedAt'] != null
        ? (data['flaggedAt'] as Timestamp).toDate()
        : null;
    final severity = data['severity'] ?? 'medium';
    final assignedTo = data['assignedTo'] ?? 'Unassigned';
    final imageUrl = data['imageUrl'];

    final badgeColor = switch (severity) {
      'high' => Colors.red,
      'low' => Colors.orange,
      _ => Colors.amber,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(issue, style: AppTextStyle.body(context)),
            const SizedBox(height: 4),
            Text(
              flaggedAt != null
                  ? "Flagged on ${DateFormat.yMMMd().add_jm().format(flaggedAt)}"
                  : "Date unavailable",
              style: AppTextStyle.caption(context),
            ),
            Text("Severity: $severity", style: AppTextStyle.caption(context)?.copyWith(color: badgeColor)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (adminList != null && onAssign != null)
                  Expanded(
                    child: AdminDropdown(
                      current: adminList!.any((a) => a["name"] == assignedTo)
                          ? adminList!.firstWhere((a) => a["name"] == assignedTo)["uid"]
                          : null,
                      admins: adminList!,
                      onChanged: onAssign!,
                    ),
                  ),
                if (showResolve && onResolve != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Resolve",
                    onPressed: onResolve,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
