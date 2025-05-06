import 'package:flutter/material.dart';
import 'dart:async';

class QRViewController {
  final _scanStreamController = StreamController<Barcode>.broadcast();

  Stream<Barcode> get scannedDataStream => _scanStreamController.stream;

  void simulateScan(String code) {
    _scanStreamController.add(Barcode(code));
  }

  void dispose() {
    _scanStreamController.close();
  }
}

class QRView extends StatefulWidget {
  final GlobalKey key;
  final void Function(QRViewController) onQRViewCreated;

  const QRView({
    required this.key,
    required this.onQRViewCreated,
  }) : super(key: key);

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  late QRViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QRViewController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onQRViewCreated(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Mock QR Scanner', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.simulateScan("mock-qr-code-123"),
            child: const Text('Simulate QR Scan'),
          ),
        ],
      ),
    );
  }
}

class Barcode {
  final String? code;
  Barcode(this.code);
}
