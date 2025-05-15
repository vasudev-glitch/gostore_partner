import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _addProduct() async {
    final name = _nameController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);

    await FirebaseFirestore.instance.collection("inventory").add({
      "name": name,
      "stock": stock,
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("➕ Add Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Initial Stock",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _addProduct,
          icon: const Icon(Icons.save),
          label: const Text("Add"),
        ),
      ],
    );
  }
}
