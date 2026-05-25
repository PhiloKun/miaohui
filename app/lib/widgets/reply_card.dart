import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reply.dart';

class ReplyCard extends StatelessWidget {
  final ReplyResult reply;
  final int index;

  const ReplyCard({super.key, required this.reply, this.index = 0});

  Color get _cardColor {
    switch (reply.style) {
      case 'humorous':
        return const Color(0xFFFFF3E0);
      case 'warm':
        return const Color(0xFFFCE4EC);
      case 'interactive':
        return const Color(0xFFE8F5E9);
      default:
        return Colors.white;
    }
  }

  Color get _darkCardColor {
    switch (reply.style) {
      case 'humorous':
        return const Color(0xFF3A2A1A);
      case 'warm':
        return const Color(0xFF3A1A2A);
      case 'interactive':
        return const Color(0xFF1A2A1A);
      default:
        return const Color(0xFF1E1E2E);
    }
  }

  Color get _accentColor {
    switch (reply.style) {
      case 'humorous':
        return const Color(0xFFFF9800);
      case 'warm':
        return const Color(0xFFE91E63);
      case 'interactive':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  IconData get _styleIcon {
    switch (reply.style) {
      case 'humorous':
        return Icons.emoji_emotions_outlined;
      case 'warm':
        return Icons.favorite_outline;
      case 'interactive':
        return Icons.motion_photos_on_outlined;
      default:
        return Icons.chat_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _darkCardColor : _cardColor;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(_styleIcon, size: 16, color: _accentColor),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reply.styleLabel,
                      style: TextStyle(
                        color: isDark ? _accentColor.withValues(alpha: 0.9) : _accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Copy button
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    color: _accentColor,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: reply.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('\u5df2\u590d\u5236\u5230\u526a\u8d34\u677f'),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reply text
              SelectableText(
                reply.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
