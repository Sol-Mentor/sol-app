import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ios_switch.dart';
import '../../../../shared/widgets/sol_ui.dart';

class HabitConfigPage extends StatefulWidget {
  const HabitConfigPage({super.key});

  @override
  State<HabitConfigPage> createState() => _HabitConfigPageState();
}

class _HabitConfigPageState extends State<HabitConfigPage> {
  String _timeOfDay = 'afternoon';
  String _frequency = 'Custom';
  bool _hasReminder = true;
  final TextEditingController _reminderHourController = TextEditingController(text: '13');
  final TextEditingController _reminderMinuteController = TextEditingController(text: '15');
  List<bool> _customDays = <bool>[false, true, true, true, true, true, false];

  static const List<({String id, String emoji, String label})> _times =
      <({String id, String emoji, String label})>[
    (id: 'morning', emoji: '🌅', label: 'Morning'),
    (id: 'afternoon', emoji: '☀️', label: 'Afternoon'),
    (id: 'evening', emoji: '🌙', label: 'Evening'),
  ];

  static const List<String> _frequencies = <String>[
    'Every day',
    'Weekdays',
    'Weekends',
    'Custom',
  ];

  static const List<String> _dayLabels = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void dispose() {
    _reminderHourController.dispose();
    _reminderMinuteController.dispose();
    super.dispose();
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
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
        ),
        leadingWidth: 88,
        title: const Text(
          'Edit habit',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: SolColors.cocoa,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SolSpacing.pageHorizontal,
          8,
          SolSpacing.pageHorizontal,
          24,
        ),
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SolColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SolColors.hair),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SolColors.coral.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🚶', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Text(
                    'Walk 10 minutes after lunch',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: SolColors.cocoa,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Sol suggested this wording. Make it yours. Specific, time bound habits are the ones that stick.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                    color: SolColors.clayDeep,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: 'TIME OF DAY'),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(_times.length, (int index) {
              final ({String id, String emoji, String label}) time = _times[index];
              final bool isSelected = _timeOfDay == time.id;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < _times.length - 1 ? 9 : 0),
                  child: Material(
                    color: isSelected ? SolColors.gold : SolColors.cream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : SolColors.hair,
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => setState(() => _timeOfDay = time.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: <Widget>[
                            Text(time.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 2),
                            Text(
                              time.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isSelected ? SolColors.cocoa : SolColors.clayDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          _SectionLabel(text: 'FREQUENCY'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            childAspectRatio: 4,
            children: _frequencies.map((String frequency) {
              final bool isSelected = _frequency == frequency;
              return Material(
                color: isSelected ? SolColors.gold.withValues(alpha: 0.12) : SolColors.cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? SolColors.gold : SolColors.hair,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _frequency = frequency),
                  child: Center(
                    child: Text(
                      frequency,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isSelected ? SolColors.goldText : SolColors.cocoa,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_frequency == 'Custom') ...<Widget>[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(_dayLabels.length, (int index) {
                final bool isSelected = _customDays[index];
                return Material(
                  color: isSelected ? SolColors.gold : SolColors.cream,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : SolColors.hair,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _customDays[index] = !_customDays[index];
                      });
                    },
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Text(
                          _dayLabels[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected ? SolColors.cocoa : SolColors.clayDeep,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: SolColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SolColors.hair),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: SolColors.gold.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text(
                          'Daily reminder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: SolColors.cocoa,
                          ),
                        ),
                      ),
                      SolIosSwitch(
                        value: _hasReminder,
                        onChanged: (bool value) => setState(() => _hasReminder = value),
                      ),
                    ],
                  ),
                ),
                if (_hasReminder) ...<Widget>[
                  const Divider(height: 1, thickness: 1, color: SolColors.hair),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Notify me at',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14.5,
                                color: SolColors.clayDeep,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: SolColors.gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _TimeField(controller: _reminderHourController),
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: SolColors.cocoa,
                                ),
                              ),
                              _TimeField(controller: _reminderMinuteController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Some habits track themselves from your watch — for those, the reminder is a gentle prompt, not a checkbox.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    height: 1.45,
                    color: SolColors.clayDeep,
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: SolColors.dawn,
            border: Border(top: BorderSide(color: SolColors.hair)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  showSolToast(
                    context,
                    title: 'Removed',
                    subtitle: 'Habit removed from your plan',
                  );
                  Navigator.of(context).maybePop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: SolColors.coralText,
                  side: const BorderSide(color: SolColors.hair, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SolPrimaryButton(
                  label: 'Save habit',
                  onPressed: () {
                    showSolToast(
                      context,
                      title: 'Saved',
                      subtitle: 'Walk 10 minutes after lunch',
                    );
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.66,
            ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: TextField(
        controller: controller,
        onChanged: (String input) {
          final String digits = input.replaceAll(RegExp(r'\D'), '');
          controller.value = TextEditingValue(
            text: digits.length <= 2 ? digits : digits.substring(0, 2),
            selection: TextSelection.collapsed(
              offset: digits.length <= 2 ? digits.length : 2,
            ),
          );
        },
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: SolColors.cocoa,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
