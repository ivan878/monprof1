import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';

class HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const HomeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: prepaPrimaryColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: prepaPrimaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: prepaPrimaryColor),
          ),
          const SizedBox(height: 14),
          SimpleText(
            text: title,
            size: 14,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ),
          const SizedBox(height: 5),
          SimpleText(
            text: subtitle,
            size: 12,
            color: Colors.grey.shade500,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
