import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final bool forAdminInvite;
  const QRScannerScreen({super.key, this.forAdminInvite = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;

  void _handleScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    if (widget.forAdminInvite && code.isNotEmpty) {
      Navigator.pop(context, code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR code")),
      );
      await Future.delayed(const Duration(seconds: 2));
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Admin Invite QR"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MobileScanner(
        fit: BoxFit.cover,
        controller: MobileScannerController(),
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) _handleScan(code);
        },
      ),
    );
  }
}
