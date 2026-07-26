import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../breathwork/presentation/pages/breathwork_page.dart';
import '../../../habit/presentation/pages/habit_config_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _domain = 'all';
  final Set<String> _addedIds = <String>{};
  final Set<String> _expandedIds = <String>{};
  final ScrollController _chipScrollController = ScrollController();

  static const List<({String id, String label})> _domains = <({String id, String label})>[
    (id: 'all', label: 'All'),
    (id: 'sleep', label: 'Sleep'),
    (id: 'movement', label: 'Movement'),
    (id: 'calm', label: 'Calm'),
    (id: 'focus', label: 'Focus'),
    (id: 'connect', label: 'Connection'),
  ];

  static const List<_DiscoverCard> _cards = <_DiscoverCard>[
    _DiscoverCard(
      id: 'wake',
      domain: 'sleep',
      icon: '☀️',
      title: 'Consistent wake time',
      why:
          'A steady wake time anchors your body clock more powerfully than bedtime does, making mornings easier and nights more reliable.',
      more:
          'Your circadian clock takes its strongest cue from when you get up, not when you lie down. Hold the wake time steady for two weeks and bedtime tends to follow on its own.',
      accent: Color(0xFF5A4FA8),
    ),
    _DiscoverCard(
      id: 'walk',
      domain: 'movement',
      icon: '🚶',
      title: 'Gentle movement',
      why:
          'Even ten minutes reliably lifts mood and energy. The lowest effort, highest return movement there is.',
      more:
          'The effect shows up at any pace, and outdoors adds a mood benefit on top. Attaching it to an existing anchor, like after lunch, is what makes it stick.',
      accent: SolColors.coralText,
    ),
    _DiscoverCard(
      id: 'stretch',
      domain: 'movement',
      icon: '🧘',
      title: 'Morning stretch',
      why:
          'A few minutes of gentle mobility eases stiffness and wakes the body up, the simplest way to start moving before the day asks anything of you.',
      more:
          'Aim for slow, comfortable range rather than deep stretches. Two to five minutes on waking is enough to reduce that first-hour stiffness most people accept as normal.',
      accent: SolColors.coralText,
    ),
    _DiscoverCard(
      id: 'calm',
      domain: 'calm',
      icon: '🪷',
      title: '5 minute breathwork',
      why:
          "A longer exhale than inhale switches on your body's calming response. Around six breaths a minute is the rate shown to best settle stress.",
      more:
          'The 4 in, 6 out ratio works because a longer exhale activates the vagus nerve. Doing it at the same time daily builds the reflex, so it is available when stress actually hits.',
      canTry: true,
      accent: Color(0xFF2E8A86),
    ),
    _DiscoverCard(
      id: 'cutoff',
      domain: 'focus',
      icon: '💻',
      title: 'Work cutoff time',
      why:
          'Mentally detaching from work predicts recovery and wellbeing even more than sleep does. The evening is where you recharge.',
      more:
          'Pick a time you can honor four days out of five, not a perfect one. The wind down that follows the cutoff is where sleep quality is actually won.',
      accent: Color(0xFF3E6FB8),
    ),
    _DiscoverCard(
      id: 'light',
      domain: 'sleep',
      icon: '🌅',
      title: 'Morning sunlight',
      why:
          "Morning light sets your circadian clock, improving both daytime alertness and that night's sleep.",
      more:
          'Cloudy daylight still delivers many times more light than indoor bulbs. No sunglasses for those minutes, and before 10am works best for setting the clock.',
      accent: SolColors.goldText,
    ),
    _DiscoverCard(
      id: 'convo',
      domain: 'connect',
      icon: '💬',
      title: 'One real conversation',
      why:
          'Social connection is the single strongest predictor of long term wellbeing. One real conversation beats many surface ones.',
      more:
          'Depth beats duration, ten real minutes counts. A standing call or walk with the same person removes the scheduling friction that usually kills this habit.',
      accent: SolColors.connection,
    ),
  ];

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  List<_DiscoverCard> get _filteredCards {
    if (_domain == 'all') {
      return _cards;
    }
    return _cards.where((_DiscoverCard card) => card.domain == _domain).toList();
  }

  Future<void> _addCard(String id) async {
    setState(() => _addedIds.add(id));
    showSolToast(
      context,
      title: 'Added to your plan',
      subtitle: 'Set the details in Edit habit',
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HabitConfigPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        SolSpacing.pageHorizontal,
        12,
        SolSpacing.pageHorizontal,
        120,
      ),
      children: <Widget>[
        Text('Discover', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Small habits, and the science behind why they work',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SolColors.clayDeep,
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 16),
        Scrollbar(
          controller: _chipScrollController,
          thickness: 3,
          radius: const Radius.circular(99),
          interactive: false,
          child: SingleChildScrollView(
            controller: _chipScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: _domains.map((({String id, String label}) domain) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _DiscoverDomainChip(
                    label: domain.label,
                    isSelected: _domain == domain.id,
                    onTap: () => setState(() => _domain = domain.id),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ..._filteredCards.map((_DiscoverCard card) {
          final bool isAdded = _addedIds.contains(card.id);
          final bool isExpanded = _expandedIds.contains(card.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DiscoverHabitCard(
              card: card,
              isAdded: isAdded,
              isExpanded: isExpanded,
              onToggleExpanded: () {
                setState(() {
                  if (isExpanded) {
                    _expandedIds.remove(card.id);
                  } else {
                    _expandedIds.add(card.id);
                  }
                });
              },
              onAdd: () => _addCard(card.id),
              onTry: card.canTry
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const BreathworkPage(),
                        ),
                      );
                    }
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _DiscoverDomainChip extends StatelessWidget {
  const _DiscoverDomainChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? SolColors.gold.withValues(alpha: 0.12) : SolColors.cream,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isSelected ? SolColors.gold : SolColors.hair,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? SolColors.goldText : SolColors.clayDeep,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverHabitCard extends StatelessWidget {
  const _DiscoverHabitCard({
    required this.card,
    required this.isAdded,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onAdd,
    this.onTry,
  });

  final _DiscoverCard card;
  final bool isAdded;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onAdd;
  final VoidCallback? onTry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SolColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SolColors.hair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: card.accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(card.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: SolColors.cocoa,
                    letterSpacing: -0.01,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'WHY IT WORKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.55,
              color: card.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.why,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  height: 1.5,
                  color: SolColors.cocoa,
                ),
          ),
          if (isExpanded) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              card.more,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    height: 1.5,
                    color: SolColors.cocoa,
                  ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onToggleExpanded,
              style: TextButton.styleFrom(
                foregroundColor: SolColors.coralText,
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded ? 'Show less' : 'Read more about this habit',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (onTry != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: onTry,
                    style: FilledButton.styleFrom(
                      backgroundColor: card.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('Try it now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AddToPlanButton(
                    isAdded: isAdded,
                    onAdd: onAdd,
                    isCompact: true,
                  ),
                ),
              ],
            )
          else
            _AddToPlanButton(isAdded: isAdded, onAdd: onAdd),
        ],
      ),
    );
  }
}

class _AddToPlanButton extends StatelessWidget {
  const _AddToPlanButton({
    required this.isAdded,
    required this.onAdd,
    this.isCompact = false,
  });

  final bool isAdded;
  final VoidCallback onAdd;
  final bool isCompact;

  String get _label {
    if (isAdded) {
      return isCompact ? 'Added' : 'Added to your plan';
    }
    return isCompact ? 'Add to plan' : 'Add to my plan';
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isAdded ? null : onAdd,
      style: FilledButton.styleFrom(
        backgroundColor: isAdded ? SolColors.cocoa.withValues(alpha: 0.06) : SolColors.cocoa,
        foregroundColor: isAdded ? SolColors.clayDeep : Colors.white,
        disabledBackgroundColor: SolColors.cocoa.withValues(alpha: 0.06),
        disabledForegroundColor: SolColors.clayDeep,
        minimumSize: const Size.fromHeight(44),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      child: isCompact
          ? Text(
              _label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!isAdded) ...<Widget>[
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    _label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DiscoverCard {
  const _DiscoverCard({
    required this.id,
    required this.domain,
    required this.icon,
    required this.title,
    required this.why,
    required this.more,
    required this.accent,
    this.canTry = false,
  });

  final String id;
  final String domain;
  final String icon;
  final String title;
  final String why;
  final String more;
  final Color accent;
  final bool canTry;
}
