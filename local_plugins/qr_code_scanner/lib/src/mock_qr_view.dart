import 'package:flutter/material.dart';

class QRViewController {
  final void Function(String code)? onScanned;

  QRViewController({this.onScanned});

  void simulateScan(String code) {
    onScanned?.call(code);
  }

  void dispose() {}
}

class QRView extends StatefulWidget {
  final QRViewController controller;
  final double width;
  final double height;

  const QRView({
    super.key,
    required this.controller,
    this.width = 300,
    this.height = 300,
  });

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Mock QR Scanner', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.controller.simulateScan("mock-qr-code-123"),
            child: const Text('Simulate QR Scan'),
          ),
        ],
      ),
    );
  }
}
