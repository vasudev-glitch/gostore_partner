import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:intl/intl.dart';

class FraudCommentThread extends StatefulWidget {
  final String fraudId;

  const FraudCommentThread({super.key, required this.fraudId});

  @override
  State<FraudCommentThread> createState() => _FraudCommentThreadState();
}

class _FraudCommentThreadState extends State<FraudCommentThread> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addComment(String message) async {
    if (message.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection("fraud_logs")
        .doc(widget.fraudId)
        .collection("comments")
        .add({
      "message": message.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text("💬 Comments", style: AppTextStyle.body(context)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("fraud_logs")
                .doc(widget.fraudId)
                .collection("comments")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Loading comments...");
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text("No comments yet.");

              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final ts = (data['timestamp'] as Timestamp?)?.toDate();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.comment, size: 18),
                    title: Text(data['message'] ?? "", style: AppTextStyle.caption(context)),
                    subtitle: Text(
                      ts != null ? DateFormat.yMMMd().add_jm().format(ts) : '',
                      style: AppTextStyle.caption(context)?.copyWith(fontSize: 11),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTextStyle.caption(context),
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _addComment(_controller.text),
              tooltip: "Send",
            ),
          ],
        )
      ],
    );
  }
}
