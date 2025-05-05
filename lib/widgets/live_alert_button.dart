import 'package:flutter/material.dart';

class LiveAlertButton extends StatefulWidget {
  final VoidCallback onPressed;
  const LiveAlertButton({super.key, required this.onPressed});

  @override
  State<LiveAlertButton> createState() => _LiveAlertButtonState();
}

class _LiveAlertButtonState extends State<LiveAlertButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.3, end: 1.0)),
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        label: const Text("LIVE"),
        icon: const Icon(Icons.bolt),
        backgroundColor: Colors.red,
      ),
    );
  }
}
