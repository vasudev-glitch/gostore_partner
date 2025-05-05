import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart'; // ✅ Centralized UI config

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  InventoryManagementScreenState createState() => InventoryManagementScreenState();
}

class InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  /// **Add New Product**
  void _addProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final stock = _stockController.text.trim();

    if (name.isEmpty || price.isEmpty || stock.isEmpty) {
      _showMessage("All fields are required!");
      return;
    }

    try {
      await _firestore.collection("inventory").add({
        "name": name,
        "price": double.parse(price),
        "stock": int.parse(stock),
        "salesCount": 0,
      });

      _showMessage("Product Added Successfully!");
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
    } catch (e) {
      _showMessage("Failed to add product: $e");
    }
  }

  /// **Show Message**
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📦 Inventory Management", style: AppTextStyle.headingLarge(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addProduct,
                style: AppButtonStyles.primary,
                child: const Text("➕ Add Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
