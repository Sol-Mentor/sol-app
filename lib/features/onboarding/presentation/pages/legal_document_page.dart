import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SolSpacing.pageHorizontal,
          8,
          SolSpacing.pageHorizontal,
          32,
        ),
        children: <Widget>[
          Text(
            body.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SolColors.cocoa,
                  height: 1.55,
                  fontSize: 14.5,
                ),
          ),
        ],
      ),
    );
  }
}
