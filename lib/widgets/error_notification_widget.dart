import 'package:flutter/material.dart';

class ErrorNotificationWidget extends StatefulWidget {
  final String errorMessage;
  final Duration duration;
  final VoidCallback? onDismissed;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  const ErrorNotificationWidget({
    super.key,
    required this.errorMessage,
    this.duration = const Duration(seconds: 12),
    this.onDismissed,
    this.backgroundColor = const Color(0xFFFFEBEE), // Light red
    this.textColor = const Color(0xFFB71C1C), // Dark red
    this.iconColor = const Color(0xFFB71C1C), // Dark red
    this.borderColor = const Color(0xFFEF9A9A), // Medium red
  });

  @override
  State<ErrorNotificationWidget> createState() => _ErrorNotificationWidgetState();
}

class _ErrorNotificationWidgetState extends State<ErrorNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    // Start animation
    _animationController.forward();

    // Auto-dismiss after the specified duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissNotification() {
    _animationController.reverse().then((_) {
      if (widget.onDismissed != null) {
        widget.onDismissed!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: widget.iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.errorMessage,
                  style: TextStyle(color: widget.textColor),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: widget.iconColor,
                onPressed: _dismissNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A manager class to handle showing error notifications throughout the app
class ErrorNotificationManager {
  // Singleton pattern
  static final ErrorNotificationManager _instance = ErrorNotificationManager._internal();
  factory ErrorNotificationManager() => _instance;
  ErrorNotificationManager._internal();

  // Method to show error notification with OverlayEntry
  static OverlayEntry? _currentOverlay;

  static void showError(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 12),
    Color backgroundColor = const Color(0xFFFFEBEE),
    Color textColor = const Color(0xFFB71C1C),
    Color iconColor = const Color(0xFFB71C1C),
    Color borderColor = const Color(0xFFEF9A9A),
  }) {
    // Remove any existing notification first
    dismissCurrentError();

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: ErrorNotificationWidget(
          errorMessage: message,
          duration: duration,
          backgroundColor: backgroundColor,
          textColor: textColor,
          iconColor: iconColor,
          borderColor: borderColor,
          onDismissed: () {
            dismissCurrentError();
          },
        ),
      ),
    );

    // Insert into overlay
    Overlay.of(context).insert(_currentOverlay!);
  }

  static void dismissCurrentError() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}