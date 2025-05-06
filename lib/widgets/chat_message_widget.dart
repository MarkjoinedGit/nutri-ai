import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
                ? const TypingIndicator()
                : isUser
                ? Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
                : MarkdownBody(
                  // 👈 Markdown cho tin nhắn bot
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, color: Colors.black87),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                    em: const TextStyle(fontStyle: FontStyle.italic),
                    code: TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
      ),
    );
  }
}

// Separated the typing indicator into its own stateful widget
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => _buildDot(index)),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate a phase offset based on the dot index
        final double phaseOffset = index * 0.2;
        final double animationValue =
            ((_controller.value + phaseOffset) % 1.0) < 0.5 ? 0.3 : 0.7;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: Colors.black54.withValues(alpha: animationValue),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
