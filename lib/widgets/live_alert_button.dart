import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LiveAlertButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool showBadge;

  const LiveAlertButton({
    super.key,
    required this.onPressed,
    this.showBadge = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return showBadge
        ? StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fraud_logs')
          .where('resolved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.warning_amber),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow,
                  ),
                  child: Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    )
        : FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.redAccent,
      child: const Icon(Icons.warning_amber),
    );
  }
}
