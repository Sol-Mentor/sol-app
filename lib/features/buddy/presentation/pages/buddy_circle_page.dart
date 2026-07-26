import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_flower.dart';
import '../../../../shared/widgets/sol_ui.dart';

class BuddyCirclePage extends StatelessWidget {
  const BuddyCirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      appBar: AppBar(
        title: const Text('Your sols circle'),
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
            'Grow alongside the sols you care about.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _BuddyCard(
            name: 'Daria',
            goal: 'Sleeping better',
            status: 'Glowing this week',
            fill: 0.85,
            onTap: () => _openDetail(
              context,
              name: 'Daria',
              goal: 'Sleeping better',
              status: 'Glowing this week',
              fill: 0.85,
              isResting: false,
            ),
          ),
          _BuddyCard(
            name: 'Ilana',
            goal: 'Feeling calmer',
            status: 'Quietly keeping on',
            fill: 0.55,
            onTap: () => _openDetail(
              context,
              name: 'Ilana',
              goal: 'Feeling calmer',
              status: 'Quietly keeping on',
              fill: 0.55,
              isResting: false,
            ),
          ),
          _BuddyCard(
            name: 'Nadav',
            goal: 'Getting stronger',
            status: 'Resting, and that\'s okay',
            fill: 0.2,
            onTap: () => _openDetail(
              context,
              name: 'Nadav',
              goal: 'Getting stronger',
              status: 'Resting, and that\'s okay',
              fill: 0.2,
              isResting: true,
            ),
          ),
          const SizedBox(height: 8),
          SolCard(
            onTap: () => _showInviteSheet(context),
            child: const Row(
              children: <Widget>[
                Icon(Icons.person_add_alt_1_outlined, color: SolColors.cocoa),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Invite someone',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: SolColors.cocoa,
                        ),
                      ),
                      Text(
                        'They get 14 days free',
                        style: TextStyle(color: SolColors.clayDeep),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SolCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const GardenVisitPage()),
              );
            },
            child: const Row(
              children: <Widget>[
                Icon(Icons.yard_outlined, color: SolColors.cocoa),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "This week's garden visit",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: SolColors.cocoa,
                        ),
                      ),
                      Text(
                        'See how your circle grew, send a little sun',
                        style: TextStyle(color: SolColors.clayDeep),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: SolColors.clayDeep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(
    BuildContext context, {
    required String name,
    required String goal,
    required String status,
    required double fill,
    required bool isResting,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuddyDetailPage(
          name: name,
          goal: goal,
          status: status,
          fill: fill,
          isResting: isResting,
        ),
      ),
    );
  }

  Future<void> _showInviteSheet(BuildContext context) async {
    bool isCopied = false;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SolColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SolSpacing.sheetRadius)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                SolSpacing.pageHorizontal,
                22,
                SolSpacing.pageHorizontal,
                MediaQuery.paddingOf(context).bottom + 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Invite a sol', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Share your link. Anyone who joins through it gets 14 days free, double the usual trial.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SolCard(
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'sol.app/join/noy-7fq2',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: SolColors.cocoa,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: 'sol.app/join/noy-7fq2'),
                            );
                            setSheetState(() => isCopied = true);
                          },
                          child: Text(isCopied ? 'Copied' : 'Copy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SolPrimaryButton(label: 'Share link', onPressed: () {}),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BuddyCard extends StatelessWidget {
  const _BuddyCard({
    required this.name,
    required this.goal,
    required this.status,
    required this.fill,
    required this.onTap,
  });

  final String name;
  final String goal;
  final String status;
  final double fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SolCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            SolProgressFlower(fill: fill, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  Text(goal, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SolColors.cocoa,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SolColors.clayDeep),
          ],
        ),
      ),
    );
  }
}

class BuddyDetailPage extends StatefulWidget {
  const BuddyDetailPage({
    super.key,
    required this.name,
    required this.goal,
    required this.status,
    required this.fill,
    required this.isResting,
  });

  final String name;
  final String goal;
  final String status;
  final double fill;
  final bool isResting;

  @override
  State<BuddyDetailPage> createState() => _BuddyDetailPageState();
}

class _BuddyDetailPageState extends State<BuddyDetailPage> {
  String? _sentMessage;

  static const List<String> _presets = <String>[
    'Sending you sun ☀',
    'Proud of you',
    'Here if you need me',
    "Let's grow this week",
  ];

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: ListView(
        padding: const EdgeInsets.all(SolSpacing.pageHorizontal),
        children: <Widget>[
          Center(child: SolProgressFlower(fill: widget.fill, size: 96)),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: SolColors.cream,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: SolColors.hair),
              ),
              child: Text(widget.goal),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              widget.status,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (widget.isResting) ...<Widget>[
            const SizedBox(height: 16),
            SolCard(
              child: Text(
                '${widget.name} is taking a quieter week. No streak to break, nothing lost. A little sun goes a long way right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            'SEND A LITTLE SUN',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 10),
          ..._presets.map((String message) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SolCard(
                onTap: () {
                  setState(() => _sentMessage = message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sent to ${widget.name}')),
                  );
                },
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SolColors.cocoa,
                  ),
                ),
              ),
            );
          }),
          if (_sentMessage != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '"$_sentMessage"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class GardenVisitPage extends StatelessWidget {
  const GardenVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<({String name, double fill})> circle = <({String name, double fill})>[
      (name: 'You', fill: 0.7),
      (name: 'Daria', fill: 0.85),
      (name: 'Ilana', fill: 0.55),
      (name: 'Nadav', fill: 0.2),
    ];

    return SolPageScaffold(
      appBar: AppBar(title: const Text("This week's garden")),
      body: ListView(
        padding: const EdgeInsets.all(SolSpacing.pageHorizontal),
        children: <Widget>[
          Text(
            'Your circle, side by side. Send a little sun to whoever could use it.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: circle.map((({String name, double fill}) person) {
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 56) / 2,
                child: SolCard(
                  child: Column(
                    children: <Widget>[
                      SolProgressFlower(fill: person.fill, size: 64),
                      const SizedBox(height: 8),
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: SolColors.cocoa,
                        ),
                      ),
                      if (person.name != 'You')
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sun sent to ${person.name}')),
                            );
                          },
                          child: const Text('Sun'),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
