import 'package:flutter/material.dart';

import '../../core/theme/sol_colors.dart';
import 'sol_mark.dart';

/// Floating mentor entry point, pinned above the bottom navigation bar.
class SolMentorFab extends StatelessWidget {
  const SolMentorFab({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const double buttonSize = 52;
  static const double markSize = 36;
  static const double rightPadding = 18;
  static const double bottomGap = 16;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sol, your mentor. Tap to chat.',
      child: Material(
        color: SolColors.cream,
        elevation: 8,
        shadowColor: SolColors.cocoa.withValues(alpha: 0.22),
        shape: CircleBorder(
          side: BorderSide(color: SolColors.hair),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Center(
              child: SolMarkRotating(size: markSize),
            ),
          ),
        ),
      ),
    );
  }
}
