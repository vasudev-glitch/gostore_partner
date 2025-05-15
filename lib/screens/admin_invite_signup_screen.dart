import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gostore_partner/screens/admin_dashboard.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AdminInviteSignupScreen extends StatefulWidget {
  final String inviteToken;
  const AdminInviteSignupScreen({super.key, required this.inviteToken});

  @override
  State<AdminInviteSignupScreen> createState() => _AdminInviteSignupScreenState();
}

class _AdminInviteSignupScreenState extends State<AdminInviteSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final inviteDoc = await FirebaseFirestore.instance
          .collection("admin_invites")
          .where("inviteToken", isEqualTo: widget.inviteToken)
          .where("used", isEqualTo: false)
          .limit(1)
          .get();

      if (inviteDoc.docs.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text("Invalid or expired invite link."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.md),
          ),
        );
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "dob": _dobController.text.trim(),
          "address": _addressController.text.trim(),
          "fatherName": _fatherNameController.text.trim(),
          "motherName": _motherNameController.text.trim(),
          "fatherPhone": _fatherPhoneController.text.trim(),
          "motherPhone": _motherPhoneController.text.trim(),
          "role": "admin",
          "timestamp": FieldValue.serverTimestamp(),
        });

        await inviteDoc.docs.first.reference.update({"used": true});

        navigator.pushReplacement(MaterialPageRoute(builder: (_) => const AdminDashboard()));
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Signup failed: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("👤 Admin Registration", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.screen,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput("Full Name", _nameController),
                  _buildInput("Email", _emailController, inputType: TextInputType.emailAddress),
                  _buildInput("Password", _passwordController, isPassword: true),
                  _buildInput("Phone Number", _phoneController, inputType: TextInputType.phone),
                  _buildInput("Date of Birth", _dobController),
                  _buildInput("Permanent Address", _addressController),
                  _buildInput("Father's Name", _fatherNameController),
                  _buildInput("Mother's Name", _motherNameController),
                  _buildInput("Father's Phone Number", _fatherPhoneController, inputType: TextInputType.phone),
                  _buildInput("Mother's Phone Number", _motherPhoneController, inputType: TextInputType.phone),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.app_registration),
                      label: const Text("Complete Registration"),
                      style: AppButtonStyles.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType inputType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
      ),
    );
  }
}
