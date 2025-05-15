import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:gostore_partner/widgets/inventory_card.dart';
import 'package:gostore_partner/widgets/inventory_header.dart';
import 'package:gostore_partner/widgets/add_product_dialog.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _updateStock(String productId, int currentStock) {
    _firestore.collection('inventory').doc(productId).update({'stock': currentStock + 1});
  }

  void _decreaseStock(String productId, int currentStock) {
    if (currentStock > 0) {
      _firestore.collection('inventory').doc(productId).update({'stock': currentStock - 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📦 Inventory", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppPaddings.screen,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('inventory').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final allDocs = snapshot.data!.docs;
            final items = allDocs.where((doc) {
              final name = (doc['name'] as String).toLowerCase();
              return name.contains(_searchQuery);
            }).toList();

            return Column(
              children: [
                InventoryHeader(
                  totalItems: allDocs.length,
                  searchController: _searchController,
                  onSearch: _updateSearch,
                ),
                const SizedBox(height: AppSpacing.lg),
                items.isEmpty
                    ? const Expanded(
                  child: Center(child: Text("No matching products found.")),
                )
                    : Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final name = item['name'] ?? 'Unnamed';
                      final stock = item['stock'] ?? 0;

                      return InventoryCard(
                        name: name,
                        stock: stock,
                        onIncrease: () => _updateStock(item.id, stock),
                        onDecrease: () => _decreaseStock(item.id, stock),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddProductDialog(),
        ),
        tooltip: "Add Product",
        child: const Icon(Icons.add),
      ),
    );
  }
}
