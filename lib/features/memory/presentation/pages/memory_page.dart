import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  late final List<_MemoryGroup> _groups;

  @override
  void initState() {
    super.initState();
    _groups = <_MemoryGroup>[
      _MemoryGroup(
        title: 'Your goal & why',
        icon: '🎯',
        items: <String>[
          "You're training for a half marathon in October.",
          'The real why: to feel strong in your body again after a hard year.',
          'You think of yourself as becoming a runner, not just doing runs.',
        ],
      ),
      _MemoryGroup(
        title: 'Things Sol has learned',
        icon: '💡',
        items: <String>[
          'Your sleep slips by about an hour on nights work runs late.',
          'You respond better to gentle data than to pep talks.',
          'Sundays are your hardest day to stay consistent.',
          'A short walk reliably lifts you out of a low afternoon.',
        ],
      ),
      _MemoryGroup(
        title: 'Your preferences',
        icon: '🎚',
        items: <String>[
          'You like reminders in the evening, not the morning.',
          "You'd rather Sol be brief on busy days.",
          'You keep your habits and goal hidden from buddies.',
        ],
      ),
    ];
  }

  void _deleteItem(int groupIndex, int itemIndex) {
    setState(() => _groups[groupIndex].items.removeAt(itemIndex));
    showSolToast(
      context,
      title: 'Forgotten',
      subtitle: "Sol won't bring that up again",
      actionLabel: 'OK',
      showCheckIcon: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: SolColors.coralText,
            padding: const EdgeInsets.only(left: 8),
          ),
          child: const Text(
            '‹ Back',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        leadingWidth: 88,
        title: const Text(
          'What Sol knows about you',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: SolColors.cocoa,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(SolSpacing.pageHorizontal),
        children: <Widget>[
          SolGradCard(
            child: Text(
              "Everything Sol remembers, in plain words. Delete anything you'd rather it forget. It's yours.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(_groups.length, (int groupIndex) {
            final _MemoryGroup group = _groups[groupIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(group.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 9),
                      Text(group.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text(
                        '${group.items.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (group.items.isEmpty)
                    SolCard(
                      child: Text(
                        'Nothing here. Sol will learn as you go.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    SolGroupedSection(
                      title: '',
                      children: List<Widget>.generate(group.items.length, (int itemIndex) {
                        final bool isLast = itemIndex == group.items.length - 1;
                        return Container(
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(bottom: BorderSide(color: SolColors.hair)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text(group.items[itemIndex])),
                              TextButton(
                                onPressed: () => _deleteItem(groupIndex, itemIndex),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: SolColors.coralText),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                ],
              ),
            );
          }),
          Text(
            'Sol never stores what you eat, your messages, or your precise location. Crisis conversations are never saved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MemoryGroup {
  _MemoryGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final String icon;
  final List<String> items;
}
