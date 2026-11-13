import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final String? label;

  const StatBadge({
    super.key,
    required this.icon,
    required this.count,
    this.iconColor = const Color(0xFFD97706),
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.label,
  });

  String _formatCount(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return NumberFormat.compact().format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor ?? const Color(0xFF1E293B),
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 3),
            Text(
              label!,
              style: TextStyle(
                fontSize: 11,
                color: textColor?.withValues(alpha: 0.8) ?? const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
