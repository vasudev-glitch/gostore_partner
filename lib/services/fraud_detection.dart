import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FraudDetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Detect & Log Fraud Cases**
  Future<void> logFraudCase(String issue) async {
    String userId = _auth.currentUser!.uid;
    String fraudId = _firestore.collection("fraud_logs").doc().id;

    await _firestore.collection("fraud_logs").doc(fraudId).set({
      "userId": userId,
      "issue": issue,
      "flaggedAt": FieldValue.serverTimestamp(),
      "resolved": false,
    });
  }
}
