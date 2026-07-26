import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../habit/presentation/pages/habit_config_page.dart';
import '../../../memory/presentation/pages/memory_page.dart';
import '../pages/delete_account_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          'Account',
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
          4,
          SolSpacing.pageHorizontal,
          32,
        ),
        children: <Widget>[
          SolGroupedSection(
            title: 'YOU & SOL',
            children: <Widget>[
              SolSettingsRow(
                title: 'What Sol knows about you',
                subtitle: 'View, edit, or delete every memory',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MemoryPage()),
                  );
                },
              ),
              SolSettingsRow(
                title: 'Your goal & direction',
                subtitle: 'Someone who moves every day',
                onTap: () {
                  showSolToast(
                    context,
                    title: 'Your goal',
                    subtitle: 'Someone who moves every day',
                  );
                },
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SolGroupedSection(
            title: 'HABITS',
            children: <Widget>[
              SolSettingsRow(
                title: 'My habits',
                subtitle: '4 active',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const HabitConfigPage()),
                  );
                },
              ),
              SolSettingsRow(
                title: 'Reminders & notifications',
                onTap: () {
                  showSolToast(
                    context,
                    title: 'Reminders',
                    subtitle: 'Evening reminders are on',
                  );
                },
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SolGroupedSection(
            title: 'PRIVACY & DATA',
            children: <Widget>[
              SolSettingsRow(
                title: 'Reset password',
                subtitle: "We'll email you a secure link",
                onTap: () {
                  showSolToast(
                    context,
                    title: 'Reset link sent',
                    subtitle: 'Check your email to set a new password',
                  );
                },
              ),
              SolSettingsRow(
                title: 'Permissions',
                subtitle: 'Health, Calendar, Notifications, Location',
                onTap: () {
                  showSolToast(
                    context,
                    title: 'Permissions',
                    subtitle: 'Health, Calendar, Notifications, Location',
                  );
                },
              ),
              SolSettingsRow(
                title: 'Connected devices',
                subtitle: 'Apple Watch',
                onTap: () {
                  showSolToast(
                    context,
                    title: 'Connected devices',
                    subtitle: 'Apple Watch',
                  );
                },
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SolGroupedSection(
            title: '',
            children: <Widget>[
              SolSettingsRow(
                title: 'Delete account & all data',
                isDestructive: true,
                isCentered: false,
                showChevron: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const DeleteAccountPage()),
                  );
                },
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Version 1.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: SolColors.clayDeep,
                ),
          ),
        ],
      ),
    );
  }
}
