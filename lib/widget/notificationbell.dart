import 'package:flutter/material.dart';


class NotificationBell extends StatefulWidget {
  final List<String> lowItems;
  final VoidCallback onPressed;

  const NotificationBell({
    super.key,
    required this.lowItems,
    required this.onPressed,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shake animation
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0), weight: 1),
    ]).animate(_controller);

    // Repeat forever if there are low items
    if (widget.lowItems.isNotEmpty) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop animation depending on low items
    if (widget.lowItems.isNotEmpty && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.lowItems.isEmpty && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: widget.lowItems.isNotEmpty ? _animation.value : 0,
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: widget.onPressed,
              ),
            );
          },
        ),
        // Badge
        if (widget.lowItems.isNotEmpty)
          Positioned(
            right: 2,
            top: 1,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  "${widget.lowItems.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
