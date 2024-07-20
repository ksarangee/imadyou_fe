import 'package:flutter/material.dart';

class ScaleArrowButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const ScaleArrowButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  _ScaleArrowButtonState createState() => _ScaleArrowButtonState();
}

class _ScaleArrowButtonState extends State<ScaleArrowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) => widget.onPressed());
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          widget.imagePath,
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
