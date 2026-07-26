import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_flower.dart';
import '../../../../shared/widgets/sol_ios_switch.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../shell/presentation/pages/main_shell_page.dart';
import '../widgets/onboarding_legal_notice.dart';
import '../widgets/year_of_birth_sheet.dart';

enum _OnboardingStep {
  welcome,
  goal,
  sport,
  build,
  plan,
  planOther,
  about,
  health,
  notify,
  done,
}

class _GoalOption {
  const _GoalOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.hue,
    required this.icon,
  });

  final String id;
  final String label;
  final String subtitle;
  final Color hue;
  final IconData icon;
}

class _HabitOption {
  _HabitOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
  }) : isOn = true;

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  bool isOn;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  final Set<String> _selectedGoalIds = <String>{};
  bool _isCustomGoal = false;
  final TextEditingController _customGoalController = TextEditingController();
  String? _selectedSport;
  String _sportQuery = '';
  int _birthYear = 1996;
  String? _gender;
  bool _healthConnected = false;
  bool _notifyConnected = false;
  List<_HabitOption> _habitStack = <_HabitOption>[];
  final List<bool> _buildChecks = <bool>[false, false, false, false];
  Timer? _buildTimer;

  static const int _maxGoals = 3;

  static const List<_GoalOption> _goals = <_GoalOption>[
    _GoalOption(
      id: 'sleep',
      label: 'Sleep better',
      subtitle: 'Deep, consistent rest',
      hue: SolColors.sleep,
      icon: Icons.nightlight_round,
    ),
    _GoalOption(
      id: 'fitness',
      label: 'Get fitter',
      subtitle: 'Pick your activity next',
      hue: SolColors.coral,
      icon: Icons.directions_run,
    ),
    _GoalOption(
      id: 'calm',
      label: 'Feel calmer',
      subtitle: 'Less stress in your days',
      hue: SolColors.calm,
      icon: Icons.waves,
    ),
    _GoalOption(
      id: 'energy',
      label: 'Higher energy',
      subtitle: 'Stop running on empty',
      hue: SolColors.coralText,
      icon: Icons.bolt,
    ),
  ];

  static const List<(String, String)> _sports = <(String, String)>[
    ('Running', '🏃'),
    ('Walking', '🚶'),
    ('Strength training', '🏋️'),
    ('Cycling', '🚴'),
    ('Swimming', '🏊'),
    ('Yoga', '🧘'),
    ('Pilates', '🤸'),
    ('Hiking', '🥾'),
    ('Football', '⚽'),
    ('Basketball', '🏀'),
    ('Tennis', '🎾'),
    ('Padel', '🎾'),
    ('Boxing', '🥊'),
    ('Climbing', '🧗'),
    ('Rowing', '🚣'),
    ('Dancing', '💃'),
    ('Martial arts', '🥋'),
    ('Skiing', '⛷️'),
    ('Surfing', '🏄'),
    ('Golf', '⛳'),
    ('Volleyball', '🏐'),
    ('CrossFit', '🤾'),
  ];

  @override
  void dispose() {
    _customGoalController.dispose();
    _buildTimer?.cancel();
    super.dispose();
  }

  bool get _hasFitnessGoal => _selectedGoalIds.contains('fitness');

  int get _activeHabitCount => _habitStack.where((_HabitOption h) => h.isOn).length;

  String get _goalLabel {
    if (_isCustomGoal) {
      return _customGoalController.text.trim().isEmpty
          ? 'your goal'
          : _customGoalController.text.trim();
    }
    if (_selectedGoalIds.length == 1) {
      return _goals.firstWhere(((_GoalOption g) => g.id == _selectedGoalIds.first)).label;
    }
    return '${_selectedGoalIds.length} directions';
  }

  List<(String, String)> get _filteredSports {
    final String query = _sportQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _sports;
    }
    return _sports.where(((String, String) sport) => sport.$1.toLowerCase().contains(query)).toList();
  }

  void _rebuildStack() {
    final List<_HabitOption> merged = <_HabitOption>[];
    for (final String goalId in _selectedGoalIds) {
      final List<_HabitOption> stack = _stackForGoal(goalId);
      for (final _HabitOption habit in stack) {
        if (!merged.any((_HabitOption item) => item.id == habit.id)) {
          merged.add(habit);
        }
      }
    }
    _habitStack = merged;
  }

  List<_HabitOption> _stackForGoal(String goalId) {
    switch (goalId) {
      case 'sleep':
        return <_HabitOption>[
          _HabitOption(
            id: 's1',
            label: 'Consistent wake time',
            subtitle: '±45 min · from your watch',
            icon: Icons.schedule,
            accent: SolColors.sleep,
          ),
          _HabitOption(
            id: 's2',
            label: 'Wind down ritual',
            subtitle: "We'll define yours together",
            icon: Icons.nightlight_round,
            accent: SolColors.sleep,
          ),
          _HabitOption(
            id: 's3',
            label: 'Personal caffeine cutoff',
            subtitle: 'Starts where you are',
            icon: Icons.local_cafe_outlined,
            accent: SolColors.goldText,
          ),
        ];
      case 'calm':
        return <_HabitOption>[
          _HabitOption(
            id: 'c1',
            label: '5 minute breathwork',
            subtitle: 'In for 4, out for 6',
            icon: Icons.spa_outlined,
            accent: SolColors.calm,
          ),
          _HabitOption(
            id: 'c2',
            label: 'Gentle movement',
            subtitle: '10 minutes, any pace',
            icon: Icons.directions_walk,
            accent: SolColors.coral,
          ),
          _HabitOption(
            id: 'c3',
            label: '2 minute journal',
            subtitle: 'Guided prompts',
            icon: Icons.edit_outlined,
            accent: SolColors.sageText,
          ),
        ];
      case 'energy':
        return <_HabitOption>[
          _HabitOption(
            id: 'e1',
            label: 'Morning sunlight',
            subtitle: '10 min · anchors your clock',
            icon: Icons.wb_sunny_outlined,
            accent: SolColors.goldText,
          ),
          _HabitOption(
            id: 'e2',
            label: 'Work cutoff time',
            subtitle: 'Real recovery',
            icon: Icons.laptop_mac_outlined,
            accent: SolColors.focus,
          ),
          _HabitOption(
            id: 'e3',
            label: 'Gentle movement',
            subtitle: '10 minutes, any pace',
            icon: Icons.directions_walk,
            accent: SolColors.coral,
          ),
        ];
      case 'fitness':
        final String sport = _selectedSport ?? 'session';
        return <_HabitOption>[
          _HabitOption(
            id: 'f1',
            label: '$sport session',
            subtitle: 'Sol sets your starting frequency',
            icon: Icons.directions_run,
            accent: SolColors.coral,
          ),
          _HabitOption(
            id: 'f2',
            label: 'Recovery day honored',
            subtitle: 'Rest is where you grow',
            icon: Icons.bedtime_outlined,
            accent: SolColors.sleep,
          ),
          _HabitOption(
            id: 'f3',
            label: 'Consistent wake time',
            subtitle: 'Adaptation loves rhythm',
            icon: Icons.schedule,
            accent: SolColors.sleep,
          ),
        ];
      default:
        return <_HabitOption>[];
    }
  }

  List<String> get _buildBeats {
    if (_selectedGoalIds.length == 1) {
      final String goalId = _selectedGoalIds.first;
      final String word = goalId == 'fitness' && _selectedSport != null
          ? _selectedSport!.toLowerCase()
          : switch (goalId) {
              'sleep' => 'better sleep',
              'calm' => 'calm',
              'energy' => 'higher energy',
              _ => 'your goal',
            };
      return <String>[
        'Reading your goal, $word',
        'Choosing habits backed by science',
        'Setting a gentle starting point',
        'Shaping it around your week',
      ];
    }
    if (_selectedGoalIds.length > 1) {
      return <String>[
        'Reading your goals',
        'Choosing habits backed by science',
        'Setting a gentle starting point',
        'Shaping it around your week',
      ];
    }
    return <String>[
      'Reading your goal',
      'Choosing habits backed by science',
      'Setting a gentle starting point',
      'Shaping it around your week',
    ];
  }

  void _goNext() {
    setState(() {
      switch (_step) {
        case _OnboardingStep.welcome:
          _step = _OnboardingStep.goal;
        case _OnboardingStep.goal:
          if (_isCustomGoal) {
            _step = _OnboardingStep.planOther;
          } else {
            _rebuildStack();
            _step = _hasFitnessGoal ? _OnboardingStep.sport : _OnboardingStep.build;
            if (_step == _OnboardingStep.build) {
              _startBuildAnimation();
            }
          }
        case _OnboardingStep.sport:
          _rebuildStack();
          _step = _OnboardingStep.build;
          _startBuildAnimation();
        case _OnboardingStep.build:
          _step = _OnboardingStep.plan;
        case _OnboardingStep.plan:
        case _OnboardingStep.planOther:
          _step = _OnboardingStep.about;
        case _OnboardingStep.about:
          _step = _OnboardingStep.health;
        case _OnboardingStep.health:
          _step = _OnboardingStep.notify;
        case _OnboardingStep.notify:
          _step = _OnboardingStep.done;
        case _OnboardingStep.done:
          break;
      }
    });
  }

  void _goBack() {
    _buildTimer?.cancel();
    setState(() {
      switch (_step) {
        case _OnboardingStep.goal:
          _step = _OnboardingStep.welcome;
        case _OnboardingStep.sport:
          _step = _OnboardingStep.goal;
        case _OnboardingStep.build:
          _step = _hasFitnessGoal ? _OnboardingStep.sport : _OnboardingStep.goal;
        case _OnboardingStep.plan:
          _step = _OnboardingStep.build;
        case _OnboardingStep.planOther:
          _step = _OnboardingStep.goal;
        case _OnboardingStep.about:
          _step = _isCustomGoal ? _OnboardingStep.planOther : _OnboardingStep.plan;
        case _OnboardingStep.health:
          _step = _OnboardingStep.about;
        case _OnboardingStep.notify:
          _step = _OnboardingStep.health;
        case _OnboardingStep.done:
          _step = _OnboardingStep.notify;
        case _OnboardingStep.welcome:
          break;
      }
    });
  }

  void _acceptOtherPlan() {
    setState(() {
      _isCustomGoal = false;
      _selectedGoalIds
        ..clear()
        ..add('energy');
      _rebuildStack();
      _step = _OnboardingStep.build;
    });
    _startBuildAnimation();
  }

  void _startBuildAnimation() {
    _buildTimer?.cancel();
    for (int i = 0; i < _buildChecks.length; i++) {
      _buildChecks[i] = false;
    }
    int index = 0;
    _buildTimer = Timer.periodic(const Duration(milliseconds: 680), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index >= _buildChecks.length) {
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 480), () {
          if (mounted) {
            setState(() => _step = _OnboardingStep.plan);
          }
        });
        return;
      }
      setState(() => _buildChecks[index] = true);
      index += 1;
    });
  }

  double get _progress {
    const List<_OnboardingStep> tracked = <_OnboardingStep>[
      _OnboardingStep.goal,
      _OnboardingStep.sport,
      _OnboardingStep.plan,
      _OnboardingStep.about,
      _OnboardingStep.health,
      _OnboardingStep.notify,
      _OnboardingStep.done,
    ];
    final int index = tracked.indexOf(_step);
    if (index < 0) {
      return 0;
    }
    return index / (tracked.length - 1);
  }

  void _enterApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShellPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showProgress = _step != _OnboardingStep.welcome &&
        _step != _OnboardingStep.build &&
        _step != _OnboardingStep.done;

    return SolPageScaffold(
      body: Column(
        children: <Widget>[
          if (showProgress) _buildTopBar(),
          Expanded(child: _buildStep(context)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 18, 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: _goBack,
            icon: const Text('‹', style: TextStyle(fontSize: 26, color: SolColors.coralText)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 4,
                backgroundColor: SolColors.cocoa.withValues(alpha: 0.08),
                color: SolColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.welcome:
        return _buildWelcome(context);
      case _OnboardingStep.goal:
        return _buildGoal(context);
      case _OnboardingStep.sport:
        return _buildSport(context);
      case _OnboardingStep.build:
        return _buildBuild(context);
      case _OnboardingStep.plan:
        return _buildPlan(context);
      case _OnboardingStep.planOther:
        return _buildPlanOther(context);
      case _OnboardingStep.about:
        return _buildAbout(context);
      case _OnboardingStep.health:
        return _buildPermission(
          title: 'Connect Apple Health',
          lead: 'Connect Health so Sol sees your movement and sleep',
          why:
              'Your habits then tick themselves off, so Sol can spot what is working without you logging a thing.',
          alertTitle: '"Sol" Would Like to Access Health',
          alertBody: 'Reads steps, workouts and sleep',
          cta: 'Connect Apple Health',
          isConnected: _healthConnected,
          onPrimary: () {
            if (!_healthConnected) {
              setState(() => _healthConnected = true);
            } else {
              _goNext();
            }
          },
        );
      case _OnboardingStep.notify:
        return _buildPermission(
          title: 'Let Sol reach you',
          lead: 'Turn on gentle nudges at the right moments, never a flood',
          why:
              'A nudge at the right moment is what turns a good plan into a habit that actually sticks.',
          alertTitle: '"Sol" Would Like to Send Notifications',
          alertBody: 'Reminders you can change anytime',
          cta: 'Turn on notifications',
          isConnected: _notifyConnected,
          onPrimary: () {
            if (!_notifyConnected) {
              setState(() => _notifyConnected = true);
            } else {
              _goNext();
            }
          },
        );
      case _OnboardingStep.done:
        return _buildDone(context);
    }
  }

  Widget _buildWelcome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: <Widget>[
          const Spacer(),
          const SolFlower(size: 150, fill: 1),
          const SizedBox(height: 24),
          Text(
            'SOL',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 3.5,
                  color: SolColors.clayDeep,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Become the best\nversion of yourself',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 33),
          ),
          const SizedBox(height: 12),
          Text(
            'Core habits, based on science.\nA mentor that learns what drives you.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          SolPrimaryButton(label: 'Get started', onPressed: _goNext),
          const SizedBox(height: 14),
          const OnboardingLegalNotice(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGoal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('What are you working toward?', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text('Start with one. Sol builds your plan around it.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: <Widget>[
                ..._goals.map((_GoalOption goal) {
                  final bool isSelected = _selectedGoalIds.contains(goal.id);
                  final bool isDimmed = !isSelected && _selectedGoalIds.length >= _maxGoals;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Opacity(
                      opacity: isDimmed ? 0.5 : 1,
                      child: _OptionRow(
                        title: goal.label,
                        subtitle: goal.subtitle,
                        icon: goal.icon,
                        hue: goal.hue,
                        isSelected: isSelected,
                        onTap: isDimmed
                            ? null
                            : () {
                                setState(() {
                                  _isCustomGoal = false;
                                  if (isSelected) {
                                    _selectedGoalIds.remove(goal.id);
                                    if (goal.id == 'fitness') {
                                      _selectedSport = null;
                                    }
                                  } else {
                                    _selectedGoalIds.add(goal.id);
                                  }
                                });
                              },
                      ),
                    ),
                  );
                }),
                if (_selectedGoalIds.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'Most people go further by nailing one first. You can always add the ${_selectedGoalIds.length == _maxGoals ? 'others' : 'rest'} once it sticks.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SolColors.goldText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
               /* Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: _isCustomGoal
                        ? SolColors.gold.withValues(alpha: 0.1)
                        : SolColors.cream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _isCustomGoal ? SolColors.gold : SolColors.hair,
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() {
                        _isCustomGoal = true;
                        _selectedGoalIds.clear();
                        _selectedSport = null;
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Something else…',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            if (_isCustomGoal) ...<Widget>[
                              const SizedBox(height: 8),
                              TextField(
                                controller: _customGoalController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText: 'Tell Sol in your own words',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: SolPrimaryButton(
              label: _isCustomGoal ? 'Continue' : 'Build my plan',
              isEnabled: _isCustomGoal
                  ? _customGoalController.text.trim().length > 1
                  : _selectedGoalIds.isNotEmpty,
              onPressed: _goNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSport(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Which activity?', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text('Pick the one you want to build around. You can change it later.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          TextField(
            onChanged: (String value) => setState(() => _sportQuery = value),
            decoration: InputDecoration(
              hintText: 'Search activities',
              prefixIcon: const Icon(Icons.search, color: SolColors.clayDeep),
              filled: true,
              fillColor: SolColors.cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SolColors.hair),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredSports.isEmpty
                ? Center(
                    child: Text(
                      'No match. Sol can still build around movement in general.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    children: _filteredSports.map(((String, String) sport) {
                      final bool isSelected = _selectedSport == sport.$1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Material(
                          color: isSelected
                              ? SolColors.gold.withValues(alpha: 0.1)
                              : SolColors.cream,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? SolColors.gold : SolColors.hair,
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _selectedSport = sport.$1),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                              child: Row(
                                children: <Widget>[
                                  Text(sport.$2, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      sport.$1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: SolColors.gold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.check, size: 13, color: SolColors.cocoa),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: SolPrimaryButton(
              label: _selectedSport == null ? 'Pick an activity' : 'Continue with $_selectedSport',
              isEnabled: _selectedSport != null,
              onPressed: _goNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuild(BuildContext context) {
    final List<String> beats = _buildBeats;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'BUILDING YOUR PLAN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 24),
            ...List<Widget>.generate(beats.length, (int index) {
              final bool isChecked = _buildChecks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 17),
                child: Row(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: isChecked ? SolColors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isChecked ? SolColors.green : SolColors.hair,
                          width: 1.5,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        beats[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'BUILT FOR: ${_goalLabel.toUpperCase()}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: SolColors.goldText),
          ),
          const SizedBox(height: 10),
          Text("Here's your habit stack", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'These few move the needle most for your goal, and they reinforce each other. Toggle anything, or trust the plan.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'The science behind each one lives in Discover.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: _habitStack.map((_HabitOption habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SolHabitStackRow(
                    title: habit.label,
                    subtitle: habit.subtitle,
                    icon: habit.icon,
                    accent: habit.accent,
                    isOn: habit.isOn,
                    onChanged: (bool value) => setState(() => habit.isOn = value),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: SolPrimaryButton(
              label: _activeHabitCount == 0
                  ? 'Pick at least one. Small is the point.'
                  : 'Start with $_activeHabitCount habit${_activeHabitCount == 1 ? '' : 's'}',
              isEnabled: _activeHabitCount > 0,
              onPressed: _goNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOther(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: <Widget>[
          const Spacer(),
          const SolFlower(size: 96, fill: 1),
          const SizedBox(height: 16),
          Text(
            "Sol doesn't do weight loss, and that's on purpose.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          Text(
            'No diets, no calories, no numbers on a scale. What Sol can do is help you feel stronger, more energetic, and more rested, through movement, sleep, and stress habits that genuinely change how you feel.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          const Text(
            'Want to start there instead?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
          const Spacer(),
          SolPrimaryButton(label: 'Yes, build that plan', onPressed: _acceptOtherPlan),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('A little about you', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Just enough to keep your habits safe. Sol never asks your weight.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 26),
          Text(
            'YEAR OF BIRTH',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                  color: SolColors.clayDeep,
                ),
          ),
          const SizedBox(height: 11),
          YearOfBirthField(
            year: _birthYear,
            onYearChanged: (int year) => setState(() => _birthYear = year),
          ),
          const SizedBox(height: 24),
          Text(
            'GENDER',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                  color: SolColors.clayDeep,
                ),
          ),
          const SizedBox(height: 11),
          GenderSelector(
            selectedGender: _gender,
            onChanged: (String gender) => setState(() => _gender = gender),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: SolColors.cream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SolColors.hair),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.shield_outlined, size: 18, color: SolColors.sageText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Used only to keep your habit targets in a safe range. No body measurements, no weight, ever.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SolColors.clayDeep,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: SolPrimaryButton(
              label: 'Continue',
              isEnabled: _gender != null,
              onPressed: _goNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermission({
    required String title,
    required String lead,
    required String why,
    required String alertTitle,
    required String alertBody,
    required String cta,
    required bool isConnected,
    required VoidCallback onPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
            decoration: BoxDecoration(
              color: SolColors.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SolColors.hair),
            ),
            child: Text(
              lead,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Spacer(),
          Container(
            width: 272,
            decoration: BoxDecoration(
              color: const Color(0xF2F9F9FB),
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Column(
                    children: <Widget>[
                      Text(
                        alertTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        alertBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.65),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x403C3C43)),
                Row(
                  children: const <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Don't Allow",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF007AFF), fontSize: 16),
                        ),
                      ),
                    ),
                    VerticalDivider(width: 1, color: Color(0x403C3C43)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Allow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(why, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          SolPrimaryButton(
            label: isConnected ? 'Continue' : cta,
            onPressed: onPrimary,
          ),
          if (!isConnected) SolSecondaryButton(label: 'Maybe later', onPressed: _goNext),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: <Widget>[
          const Spacer(),
          const SolFlower(size: 130, fill: 1, state: SolFlowerState.celebrating),
          const SizedBox(height: 16),
          Text("You're in", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 29)),
          const SizedBox(height: 8),
          Text(
            '$_activeHabitCount habits, one direction. Create your account to save your progress.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _enterApp,
            icon: const Icon(Icons.apple, size: 19),
            label: const Text('Continue with Apple'),
            style: FilledButton.styleFrom(
              backgroundColor: SolColors.cocoa,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton(
            onPressed: _enterApp,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.white,
              side: const BorderSide(color: SolColors.hair, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _enterApp,
            child: const Text(
              'Sign up with email',
              style: TextStyle(color: SolColors.coralText, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '7 days free, full access. Then ₪39.90/month. Cancel anytime.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _step = _OnboardingStep.welcome;
                _selectedGoalIds.clear();
                _isCustomGoal = false;
                _customGoalController.clear();
                _habitStack = <_HabitOption>[];
                _selectedSport = null;
                _gender = null;
                _healthConnected = false;
                _notifyConnected = false;
              });
            },
            child: const Text('Restart demo'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hue,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color hue;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? SolColors.gold.withValues(alpha: 0.1) : SolColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? SolColors.gold : SolColors.hair,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, color: hue),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? SolColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? SolColors.gold : SolColors.hair, width: 1.5),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 13, color: SolColors.cocoa)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
