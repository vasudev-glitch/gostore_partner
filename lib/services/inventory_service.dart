import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Track Best-Selling Products**
  Future<void> updateProductSales(String productId) async {
    DocumentReference productRef = _firestore.collection("inventory").doc(productId);
    await productRef.update({"salesCount": FieldValue.increment(1)});
  }
}
