import 'package:flutter/material.dart';

/// Counts up to [value] on first build — common fintech hero pattern.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    required this.format,
    this.duration = const Duration(milliseconds: 900),
  });

  final num value;
  final TextStyle style;
  final String Function(double) format;
  final Duration duration;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _display = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
      ..addListener(() {
        setState(() {
          _display = _animation.value * widget.value.toDouble();
        });
      });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final from = _display;
      _controller.reset();
      _animation = Tween<double>(begin: from, end: widget.value.toDouble())
          .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      )..addListener(() {
          setState(() => _display = _animation.value);
        });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.format(_display),
      style: widget.style,
    );
  }
}
