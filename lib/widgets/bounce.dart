import 'package:flutter/material.dart';

class Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const Bouncing({required this.child, required this.onPressed, super.key});

  @override
  State<Bouncing> createState() => _BouncingState();
}

class _BouncingState extends State<Bouncing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    // Dispose of the controller before calling super.dispose().
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the scale value based on the controller's value.
    final double scale = 1 - _controller.value;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (mounted) {
          _controller.forward();
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (mounted) {
          _controller.reverse(); // Ensure widget is mounted before calling.
          widget.onPressed();
        }
      },
      child: Transform.scale(scale: scale, child: widget.child),
    );
  }
}
