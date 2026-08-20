import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/Utils/StepCounter/step_counter.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../breathwork/presentation/pages/breathwork_page.dart';
import '../../../habit/presentation/pages/habit_config_page.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    super.key,
    required this.stepCounter,
  });

  final StepCounter stepCounter;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStepCounter();
    });
  }

  Future<void> _startStepCounter() async {
    try {
      await widget.stepCounter.start();
    } catch (error) {
      if (!mounted) {
        return;
      }

      showSolToast(
        context,
        title: 'Step tracking unavailable',
        subtitle: error.toString(),
        aboveBottomNav: true,
      );
    }
  }

  final List<_TodayHabit> _habits = <_TodayHabit>[
    const _TodayHabit(
      id: 'walk',
      icon: '🚶',
      name: 'Walk 10 minutes after lunch',
      subtitle: 'Afternoon',
      isDone: true,
      isEditable: true,
    ),
    const _TodayHabit(
      id: 'sun',
      icon: '☀️',
      name: 'Morning sunlight',
      subtitle: '10 min, tracked by your watch',
      isDone: true,
    ),
    const _TodayHabit(
      id: 'wind',
      icon: '🌙',
      name: 'Wind down by 10:30',
      subtitle: 'Evening',
    ),
    const _TodayHabit(
      id: 'breathe',
      icon: '🪷',
      name: '5 minute breathwork',
      subtitle: 'Guided session',
      opensBreathwork: true,
    ),
  ];

  int get _doneCount =>
      _habits.where((_TodayHabit h) => h.isDone).length;

  void _toggleHabit(int index) {
    setState(() {
      final _TodayHabit habit = _habits[index];

      _habits[index] = habit.copyWith(
        isDone: !habit.isDone,
      );
    });

    if (_habits[index].isDone) {
      showSolToast(
        context,
        title: 'Marked done',
        subtitle: _habits[index].name,
        aboveBottomNav: true,
      );
    }
  }

  Future<void> _openHabit(int index) async {
    final _TodayHabit habit = _habits[index];

    if (habit.opensBreathwork) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const BreathworkPage(),
        ),
      );

      return;
    }

    if (habit.isEditable) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const HabitConfigPage(),
        ),
      );
    } else {
      _toggleHabit(index);
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              'Today',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(width: 10),
            Text(
              '$_doneCount/${_habits.length} habits done',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Fact of the day
        SolGradCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Fact of the day',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SolColors.cocoa.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ten minutes of morning light can shift your sleep earlier '
                    'the same night. Your eyes set the clock for the whole day.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: SolColors.cocoa,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Live step counter
        _StepsCard(
          stepCounter: widget.stepCounter,
        ),

        const SizedBox(height: 14),

        // Habits
        ...List<Widget>.generate(
          _habits.length,
              (int index) {
            final _TodayHabit habit = _habits[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HabitTile(
                habit: habit,
                onTap: () => _openHabit(index),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({
    required this.stepCounter,
  });

  final StepCounter stepCounter;

  @override
  Widget build(BuildContext context) {
    return SolGradCard(
      child: Row(
        children: <Widget>[
          // Walking icon
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SolColors.tile,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: SolColors.cocoa,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          // Step information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Steps today',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                    SolColors.cocoa.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 2),

                StreamBuilder<int>(
                  stream: stepCounter.stepCountStream,
                  initialData: stepCounter.currentSteps,
                  builder: (
                      BuildContext context,
                      AsyncSnapshot<int> snapshot,
                      ) {
                    final int steps =
                        snapshot.data ?? stepCounter.currentSteps;

                    return AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      child: Text(
                        _formatSteps(steps),
                        key: ValueKey<int>(steps),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: SolColors.cocoa,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                Text(
                  'Updates automatically as you walk',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: SolColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Live',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SolColors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSteps(int steps) {
    final String digits = steps.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final int remaining = digits.length - i;

      result.write(digits[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        result.write(',');
      }
    }

    return result.toString();
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.onTap,
  });

  final _TodayHabit habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: habit.isDone
                ? SolColors.cocoa.withValues(alpha: 0.04)
                : SolColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SolColors.hair,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SolColors.tile,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  habit.icon,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        color: SolColors.cocoa,
                        decoration: habit.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      habit.subtitle,
                      style:
                      Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              if (habit.opensBreathwork)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: SolColors.calm,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: habit.isDone
                        ? SolColors.green
                        : SolColors.cocoa.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: habit.isDone
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayHabit {
  const _TodayHabit({
    required this.id,
    required this.icon,
    required this.name,
    required this.subtitle,
    this.isDone = false,
    this.isEditable = false,
    this.opensBreathwork = false,
  });

  final String id;
  final String icon;
  final String name;
  final String subtitle;
  final bool isDone;
  final bool isEditable;
  final bool opensBreathwork;

  _TodayHabit copyWith({
    bool? isDone,
  }) {
    return _TodayHabit(
      id: id,
      icon: icon,
      name: name,
      subtitle: subtitle,
      isDone: isDone ?? this.isDone,
      isEditable: isEditable,
      opensBreathwork: opensBreathwork,
    );
  }
}