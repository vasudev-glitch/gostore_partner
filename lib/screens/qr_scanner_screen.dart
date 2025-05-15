import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gostore_partner/utils/ui_config.dart';

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
    setState(() => isProcessing = true);

    if (widget.forAdminInvite && code.isNotEmpty) {
      Navigator.pop(context, code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Invalid QR code"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📲 Scan QR Code", style: AppTextStyle.headingLarge(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            controller: MobileScannerController(),
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue;
              if (code != null) _handleScan(code);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_scanner, size: 64, color: Colors.white70),
              ),
            ),
          ),
          if (isProcessing)
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
