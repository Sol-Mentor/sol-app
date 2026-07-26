import 'package:flutter/material.dart';

import '../../core/constants/sol_spacing.dart';
import '../../core/theme/sol_colors.dart';
import 'sol_bottom_nav.dart';

/// App scaffold that keeps page content inside [SafeArea] insets on all devices.
class SolPageScaffold extends StatelessWidget {
  const SolPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor = SolColors.dawn,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.safeAreaTop,
    this.safeAreaBottom,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool? safeAreaTop;
  final bool? safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final bool hasAppBar = appBar != null;
    final bool hasBottomBar = bottomNavigationBar != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: SafeArea(
        top: safeAreaTop ?? !hasAppBar,
        bottom: safeAreaBottom ?? !hasBottomBar,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SolPrimaryButton extends StatelessWidget {
  const SolPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = FilledButton(
      onPressed: isEnabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: SolColors.coralText,
        foregroundColor: SolColors.cream,
        disabledBackgroundColor: SolColors.cocoa.withValues(alpha: 0.08),
        disabledForegroundColor: SolColors.clayDeep,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      child: Text(label),
    );
    if (!isExpanded) {
      return button;
    }
    return SizedBox(width: double.infinity, child: button);
  }
}

class SolSecondaryButton extends StatelessWidget {
  const SolSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: SolColors.coralText,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class SolCard extends StatelessWidget {
  const SolCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: SolColors.cream,
        borderRadius: BorderRadius.circular(SolSpacing.cardRadius),
        border: Border.all(color: SolColors.hair),
      ),
      child: child,
    );
    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SolSpacing.cardRadius),
        child: content,
      ),
    );
  }
}

class SolGradCard extends StatelessWidget {
  const SolGradCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            SolColors.peach,
            SolColors.coral.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(SolSpacing.cardRadius),
        border: Border.all(color: SolColors.hair),
      ),
      child: child,
    );
  }
}

class SolGroupedSection extends StatelessWidget {
  const SolGroupedSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.66,
                  ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: SolColors.cream,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SolColors.hair),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class SolSettingsRow extends StatelessWidget {
  const SolSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
    this.isCentered = false,
    this.isLast = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showChevron;
  final bool isCentered;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        isDestructive ? SolColors.iosRed : SolColors.cocoa;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: SolColors.hair)),
          ),
          child: isCentered
              ? Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: titleColor,
                  ),
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: titleColor,
                            ),
                          ),
                          if (subtitle != null) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showChevron && !isDestructive)
                      const Icon(
                        Icons.chevron_right,
                        color: SolColors.clayDeep,
                        size: 18,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SolSectionHeader extends StatelessWidget {
  const SolSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: SolColors.coralText,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ),
      ],
    );
  }
}

class SolChip extends StatelessWidget {
  const SolChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = selectedColor ?? SolColors.cocoa;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : SolColors.cream,
          borderRadius: BorderRadius.circular(SolSpacing.pillRadius),
          border: Border.all(
            color: isSelected ? activeColor : SolColors.hair,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? SolColors.cream : SolColors.cocoa,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

void showSolToast(
  BuildContext context, {
  required String title,
  String? subtitle,
  bool aboveBottomNav = false,
  String? actionLabel,
  bool showCheckIcon = false,
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final double bottomMargin = aboveBottomNav
      ? SolBottomNav.heightOf(context) + 12
      : MediaQuery.paddingOf(context).bottom + 24;

  final bool useActionLayout = showCheckIcon || actionLabel != null;

  final Widget content = useActionLayout
      ? Row(
          children: <Widget>[
            if (showCheckIcon)
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            if (showCheckIcon) const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: messenger.hideCurrentSnackBar,
                style: TextButton.styleFrom(
                  foregroundColor: SolColors.peach,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: SolColors.cream.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
          ],
        );

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      padding: useActionLayout
          ? const EdgeInsets.symmetric(horizontal: 15, vertical: 13)
          : null,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: SolColors.dusk,
      content: content,
      duration: const Duration(milliseconds: 4000),
    ),
  );
}
