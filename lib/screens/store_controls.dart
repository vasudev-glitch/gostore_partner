import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gostore_partner/utils/ui_config.dart';
import 'package:intl/intl.dart';

class StoreControlsScreen extends StatefulWidget {
  const StoreControlsScreen({super.key});

  @override
  StoreControlsScreenState createState() => StoreControlsScreenState();
}

class StoreControlsScreenState extends State<StoreControlsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isOpen = true;
  bool _isUpdating = false;
  String? _lastModifiedBy;
  Timestamp? _lastModifiedAt;

  @override
  void initState() {
    super.initState();
    _listenToStatus();
  }

  void _listenToStatus() {
    _firestore.collection("store_settings").doc("access_control").snapshots().listen((doc) {
      final data = doc.data();
      if (data == null) return;
      setState(() {
        _isOpen = data['isOpen'] ?? true;
        _lastModifiedBy = data['modifiedBy'];
        _lastModifiedAt = data['modifiedAt'];
      });
    });
  }

  Future<void> _toggleStore(bool value) async {
    setState(() => _isUpdating = true);

    await _firestore.collection("store_settings").doc("access_control").set({
      "isOpen": value,
      "modifiedBy": FirebaseFirestore.instance.app.name, // Replace with actual admin name if available
      "modifiedAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Store is now ${value ? 'OPEN ✅' : 'CLOSED 🚪'}"),
        backgroundColor: value ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );

    setState(() => _isUpdating = false);
  }

  Widget _buildStatusIndicator() {
    final color = _isOpen ? Colors.green : Colors.red;
    final text = _isOpen ? "STORE IS OPEN" : "STORE IS CLOSED";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_isOpen ? Icons.lock_open : Icons.lock, color: color),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyle.body(context).copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildLastModifiedInfo() {
    if (_lastModifiedAt == null) return const SizedBox.shrink();

    final dateTime = _lastModifiedAt!.toDate();
    final formatted = DateFormat.yMMMd().add_jm().format(dateTime);
    final by = _lastModifiedBy ?? "Unknown";

    return Text("Last updated by $by on $formatted", style: AppTextStyle.caption(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🔧 Store Controls", style: AppTextStyle.headingLarge(context)),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppPaddings.screen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIndicator(),
            const SizedBox(height: AppSpacing.md),
            _buildLastModifiedInfo(),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile.adaptive(
              value: _isOpen,
              onChanged: _isUpdating ? null : _toggleStore,
              title: Text(
                _isOpen ? "Toggle to Close Store" : "Toggle to Open Store",
                style: AppTextStyle.body(context),
              ),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
