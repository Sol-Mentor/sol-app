import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/sol_colors.dart';

class SolIosSwitch extends StatelessWidget {
  const SolIosSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const Color _inactiveTrackColor = Color(0x3C787880);

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: SolColors.green,
      inactiveTrackColor: _inactiveTrackColor,
    );
  }
}

class SolHabitStackRow extends StatelessWidget {
  const SolHabitStackRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.isOn,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isOn ? 1 : 0.6,
      child: Material(
        color: isOn ? SolColors.gold.withValues(alpha: 0.1) : SolColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isOn ? SolColors.gold : SolColors.cocoa.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!isOn),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: SolColors.cocoa,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SolIosSwitch(
                  value: isOn,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
