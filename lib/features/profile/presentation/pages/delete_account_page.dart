import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _isAcknowledged = false;
  final TextEditingController _passwordController = TextEditingController();

  bool get _canDelete => _isAcknowledged && _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
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
            '‹ Cancel',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        leadingWidth: 96,
        title: const Text(
          'Delete account',
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
          const _DeleteWarningBanner(),
          const SizedBox(height: 22),
          Text(
            'WHAT GETS DELETED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.66,
                ),
          ),
          const SizedBox(height: 10),
          SolGroupedSection(
            title: '',
            children: const <Widget>[
              _DeleteItem(text: 'Every memory and insight'),
              _DeleteItem(text: 'Your goal, habits, and reminders'),
              _DeleteItem(text: 'Your full journey and moments'),
              _DeleteItem(
                text: 'All connected data from Health and Calendar',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => setState(() => _isAcknowledged = !_isAcknowledged),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isAcknowledged ? SolColors.iosRed : SolColors.cream,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:_isAcknowledged ? SolColors.iosRed :  SolColors.clayDeep.withValues(alpha: 0.28),
                      width: 1.5,
                    ),
                  ),
                  child: _isAcknowledged
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I understand this permanently deletes my account and cannot be reversed.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13.5,
                          height: 1.45,
                          color: SolColors.cocoa,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            "CONFIRM IT'S YOU",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.66,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: SolColors.cocoa,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: SolColors.clayDeep.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: SolColors.cream,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: SolColors.hair, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: SolColors.cocoa.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'For your security, Sol asks for your password before deleting anything.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  height: 1.45,
                ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(height: 1, thickness: 1, color: SolColors.hair),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: FilledButton(
                onPressed: _canDelete ? _deleteAccount : null,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _canDelete ? SolColors.destructive : SolColors.cream,
                  foregroundColor:
                      _canDelete ? Colors.white : SolColors.seedEnd,
                  disabledBackgroundColor: SolColors.cream,
                  disabledForegroundColor: SolColors.seedEnd,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                child: const Text('Delete my account'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showSolToast(
      context,
      title: 'Account deleted',
      subtitle: 'This is a prototype, nothing was really removed',
    );
    Navigator.of(context).pop();
  }
}

class _DeleteWarningBanner extends StatelessWidget {
  const _DeleteWarningBanner();

  static const Color _warningFill = Color(0xFFFCECEA);
  static const Color _warningBorder = Color(0xFFE8B4AE);
  static const Color _iconFill = Color(0xFFF5D0CB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _warningFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _iconFill,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  '⚠️',
                  style: TextStyle(fontSize: 19, height: 1),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'This cannot be undone',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: SolColors.iosRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Deleting your account permanently removes your habits, your journey, and everything Sol remembers about you. There is no way to recover it afterward.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SolColors.cocoa,
                  fontSize: 14,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  const _DeleteItem({required this.text, this.isLast = false});

  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: SolColors.hair)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SolColors.cocoa,
              fontSize: 14,
            ),
      ),
    );
  }
}
