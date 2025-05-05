import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAdminInviteButton extends StatelessWidget {
  const AddAdminInviteButton({super.key});

  Future<void> _sendInvite(BuildContext context, String email) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Generate unique invite token
      final token = DateTime.now().millisecondsSinceEpoch.toString();

      // Store invite record in Firestore
      await FirebaseFirestore.instance.collection('admin_invites').doc(email).set({
        'email': email,
        'inviteToken': token,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      // (In production) Trigger Firebase Cloud Function to send email with invite link
      // Example link: https://your-app.com/admin-signup?inviteToken=TOKEN

      messenger.showSnackBar(
        SnackBar(content: Text("✅ Invite link has been sent to $email")),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error sending invite: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Add Admin"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Send Admin Invite"),
            content: TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Enter admin's email"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _sendInvite(context, emailController.text.trim());
                  Navigator.pop(context);
                },
                child: const Text("Send Invite"),
              ),
            ],
          ),
        );
      },
    );
  }
}
