import 'package:flutter/material.dart';

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;
  static const Color customOrange = Color(0xFFE07E02);

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isUser ? 64 : 0,
          right: isUser ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? customOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            isTyping && !isUser
                ? _buildTypingIndicator()
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? Colors.white : Colors.black87,
                  ),
                ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_buildDot(0), _buildDot(1), _buildDot(2)],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: TypingDotsAnimation(),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: Colors.black54.withValues(alpha:
              // Each dot animates with a slight delay
              (TypingDotsAnimation.getValue() + (index * 0.3)) % 1.0 < 0.5
                  ? 0.3
                  : 0.7,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class TypingDotsAnimation extends Animation<double> with AnimationLinkMixin {
  static double _value = 0;
  static bool _isAnimating = true;

  TypingDotsAnimation() {
    if (_isAnimating) {
      _startAnimation();
    }
  }

  static double getValue() => _value;

  void _startAnimation() {
    _isAnimating = true;
    _animate();
  }

  void _animate() {
    if (!_isAnimating) return;
    _value = (_value + 0.1) % 1.0;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), _animate);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _isAnimating = false;
    }
  }

  @override
  double get value => _value;
}

// Animation link mixin
mixin AnimationLinkMixin on Animation<double> {
  final List<VoidCallback> _listeners = [];
  final List<AnimationStatusListener> _statusListeners = [];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    _statusListeners.add(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _statusListeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      if (_listeners.contains(listener)) {
        listener();
      }
    }
  }

  bool get hasListeners => _listeners.isNotEmpty;

  @override
  bool get isCompleted => false;

  @override
  AnimationStatus get status => AnimationStatus.forward;
}
