import 'package:flutter/material.dart';
import 'package:gostore_partner/local_plugins/qr_code_scanner/lib/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final bool forAdminInvite;
  const QRScannerScreen({super.key, this.forAdminInvite = false});

  @override
  QRScannerScreenState createState() => QRScannerScreenState();
}

class QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (isProcessing) return;
      isProcessing = true;

      final scannedValue = scanData.code ?? "";
      final navigator = Navigator.of(context);

      if (widget.forAdminInvite && scannedValue.isNotEmpty) {
        navigator.pop(scannedValue);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid QR code")),
        );
        await Future.delayed(const Duration(seconds: 2));
        isProcessing = false;
      }
    });
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
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}
