import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class InventoryHeader extends StatelessWidget {
  final int totalItems;
  final TextEditingController searchController;
  final void Function(String) onSearch;

  const InventoryHeader({
    super.key,
    required this.totalItems,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Inventory Overview", style: AppTextStyle.headingLarge(context)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Products: $totalItems", style: AppTextStyle.caption(context)),
            IconButton(
              onPressed: () => searchController.clear(),
              icon: const Icon(Icons.clear),
              tooltip: "Clear search",
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: '🔍 Search products...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }
}
