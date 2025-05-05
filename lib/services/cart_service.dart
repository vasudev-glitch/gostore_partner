import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Clears the user's cart after checkout**
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({'cart': []});

      if (kDebugMode) {
        debugPrint("[CartService] Cart cleared successfully for user: $userId");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[CartService] Error clearing cart: $e");
      }
    }
  }

  /// **Checks if the product is in stock before adding it to the cart**
  Future<bool> checkStock(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
      await _firestore.collection('inventory').doc(productId).get();

      if (!productSnapshot.exists) {
        if (kDebugMode) debugPrint("[CartService] Product not found: $productId");
        return false;
      }

      int stock = productSnapshot["stock"] ?? 0;
      return stock > 0;
    } catch (e) {
      if (kDebugMode) debugPrint("[CartService] Error checking stock: $e");
      return false;
    }
  }

  /// **Adds an item to the cart only if it's in stock**
  Future<void> addItemToCart(String userId, String productId) async {
    try {
      bool inStock = await checkStock(productId);
      if (!inStock) {
        if (kDebugMode) debugPrint("[CartService] Product is out of stock: $productId");
        return;
      }

      DocumentSnapshot productSnapshot =
      await _firestore.collection('inventory').doc(productId).get();

      Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(productId)
          .set({
        "name": productData["name"],
        "price": productData["price"],
        "timestamp": FieldValue.serverTimestamp(), // ✅ Auto-generates timestamp
      });

      if (kDebugMode) debugPrint("[CartService] Item added to cart: $productId");
    } catch (e) {
      if (kDebugMode) debugPrint("[CartService] Error adding item to cart: $e");
    }
  }

  /// **Updates stock after a successful purchase**
  Future<void> updateStockAfterPurchase(String productId) async {
    DocumentReference productRef = _firestore.collection('inventory').doc(productId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot productSnapshot = await transaction.get(productRef);
      if (!productSnapshot.exists) return;

      int currentStock = productSnapshot["stock"] ?? 0;
      if (currentStock > 0) {
        transaction.update(productRef, {
          "stock": currentStock - 1,
          "lastUpdated": FieldValue.serverTimestamp() // ✅ Tracks stock update timestamp
        });
      }
    });

    if (kDebugMode) debugPrint("[CartService] Stock updated for product: $productId");
  }

  /// **Saves purchase history with timestamp**
  Future<void> savePurchaseHistory(String userId, String productId) async {
    try {
      DocumentSnapshot productSnapshot =
      await _firestore.collection("inventory").doc(productId).get();

      if (!productSnapshot.exists) return;

      Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("purchase_history")
          .add({
        "productId": productId,
        "name": productData["name"],
        "price": productData["price"],
        "timestamp": FieldValue.serverTimestamp(), // ✅ Tracks purchase timestamp
      });

      if (kDebugMode) debugPrint("[CartService] Purchase history updated for user: $userId");
    } catch (e) {
      if (kDebugMode) debugPrint("[CartService] Error saving purchase history: $e");
    }
  }
}
