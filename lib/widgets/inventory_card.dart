import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class InventoryCard extends StatelessWidget {
  final String name;
  final int stock;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const InventoryCard({
    super.key,
    required this.name,
    required this.stock,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = stock < 5;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name, style: AppTextStyle.body(context)),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("Low Stock", style: AppTextStyle.caption(context)?.copyWith(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Stock: $stock", style: AppTextStyle.caption(context)),
                Row(
                  children: [
                    IconButton(
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: "Decrease stock",
                    ),
                    IconButton(
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: "Increase stock",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
