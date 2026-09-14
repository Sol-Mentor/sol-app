import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/Utils/StepCounter/step_counter.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_bottom_nav.dart';
import '../../../../shared/widgets/sol_mentor_fab.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../journey/presentation/pages/journey_page.dart';
import '../../../mentor/presentation/pages/mentor_chat_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../today/presentation/pages/today_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    required this.stepCounter,
  });

  final StepCounter stepCounter;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  SolTab _currentTab = SolTab.today;

  void _openMentor() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MentorChatPage(),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          IndexedStack(
            index: _currentTab.index,
            children: <Widget>[
              const JourneyPage(),

              TodayPage(
                stepCounter: widget.stepCounter,
              ),

              const DiscoverPage(),
            ],
          ),

          Positioned(
            top: 8,
            right: 18,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openAccount,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        SolColors.peach,
                        SolColors.coral,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: SolColors.cocoa.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'N',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: SolColors.cocoa,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: SolMentorFab.rightPadding,
            bottom: SolMentorFab.bottomGap,
            child: SolMentorFab(
              onTap: _openMentor,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SolBottomNav(
        currentTab: _currentTab,
        onTabSelected: (SolTab tab) {
          setState(() {
            _currentTab = tab;
          });
        },
      ),
    );
  }
}