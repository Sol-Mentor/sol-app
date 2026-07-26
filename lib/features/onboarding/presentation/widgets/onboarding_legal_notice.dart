import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/sol_colors.dart';
import '../../data/legal_content.dart';
import '../pages/legal_document_page.dart';

class OnboardingLegalNotice extends StatefulWidget {
  const OnboardingLegalNotice({super.key});

  @override
  State<OnboardingLegalNotice> createState() => _OnboardingLegalNoticeState();
}

class _OnboardingLegalNoticeState extends State<OnboardingLegalNotice> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openDocument(
            title: LegalContent.termsTitle,
            body: LegalContent.termsBody,
          );
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openDocument(
            title: LegalContent.privacyTitle,
            body: LegalContent.privacyBody,
          );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openDocument({
    required String title,
    required String body,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentPage(title: title, body: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: SolColors.clayDeep,
          height: 1.5,
          fontSize: 11.5,
        );
    const TextStyle linkStyle = TextStyle(
      color: SolColors.coralText,
      fontWeight: FontWeight.w600,
      fontSize: 11.5,
      height: 1.5,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: <InlineSpan>[
          const TextSpan(text: "By continuing, you agree to Sol's "),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(
            text: ". Sol supports healthy habits and isn't medical advice.",
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
