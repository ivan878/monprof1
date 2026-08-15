import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          SimpleText(text: title, size: 16, weight: FontWeight.bold),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: SimpleText(
                text: actionLabel!,
                size: 13,
                color: prepaPrimaryColor,
                weight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
