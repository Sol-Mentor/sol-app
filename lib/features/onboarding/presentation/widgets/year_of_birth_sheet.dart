import 'package:flutter/material.dart';

import '../../../../core/theme/sol_colors.dart';

class YearOfBirthSheet extends StatefulWidget {
  const YearOfBirthSheet({
    super.key,
    required this.initialYear,
  });

  final int initialYear;

  static const int _minYear = 1940;
  static const int _maxYear = 2008;

  static Future<int?> show(
    BuildContext context, {
    required int initialYear,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: SolColors.dawn,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return YearOfBirthSheet(initialYear: initialYear);
      },
    );
  }

  @override
  State<YearOfBirthSheet> createState() => _YearOfBirthSheetState();
}

class _YearOfBirthSheetState extends State<YearOfBirthSheet> {
  static final List<int> _years = List<int>.generate(
    YearOfBirthSheet._maxYear - YearOfBirthSheet._minYear + 1,
    (int index) => YearOfBirthSheet._maxYear - index,
  );

  late int _selectedYear;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    final int initialIndex = _years.indexOf(_selectedYear);
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 38,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: SolColors.cocoa.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Year of birth',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: SolColors.cocoa,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedYear),
                  style: TextButton.styleFrom(
                    foregroundColor: SolColors.coralText,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: Stack(
              children: <Widget>[
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 44,
                  physics: const FixedExtentScrollPhysics(),
                  diameterRatio: 1.35,
                  perspective: 0.003,
                  onSelectedItemChanged: (int index) {
                    setState(() => _selectedYear = _years[index]);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _years.length,
                    builder: (BuildContext context, int index) {
                      final int year = _years[index];
                      final bool isSelected = year == _selectedYear;
                      return Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? SolColors.cocoa
                                : SolColors.clayDeep.withValues(alpha: 0.4),
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: SolColors.gold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const IgnorePointer(
                  child: _YearPickerFadeOverlay(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _YearPickerFadeOverlay extends StatelessWidget {
  const _YearPickerFadeOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  SolColors.dawn,
                  SolColors.dawn.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  SolColors.dawn,
                  SolColors.dawn.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class YearOfBirthField extends StatelessWidget {
  const YearOfBirthField({
    super.key,
    required this.year,
    required this.onYearChanged,
  });

  final int year;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SolColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: SolColors.hair),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final int? nextYear = await YearOfBirthSheet.show(
            context,
            initialYear: year,
          );
          if (nextYear != null) {
            onYearChanged(nextYear);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$year',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: SolColors.cocoa,
                    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const Text(
                'Tap to change',
                style: TextStyle(
                  fontSize: 12.5,
                  color: SolColors.clayDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  final String? selectedGender;
  final ValueChanged<String> onChanged;

  static const List<String> _options = <String>['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(_options.length, (int index) {
        final String label = _options[index];
        final bool isSelected = selectedGender == label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < _options.length - 1 ? 9 : 0),
            child: Material(
              color: isSelected ? SolColors.gold.withValues(alpha: 0.12) : SolColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? SolColors.gold : SolColors.hair,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(label),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isSelected ? SolColors.goldText : SolColors.cocoa,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
