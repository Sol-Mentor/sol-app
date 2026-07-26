import 'package:flutter/material.dart';

import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_flower.dart';
import '../../../../shared/widgets/sol_mark.dart';
import '../../../../shared/widgets/sol_ui.dart';
import '../../../memory/presentation/pages/memory_page.dart';

class MentorChatPage extends StatefulWidget {
  const MentorChatPage({super.key});

  @override
  State<MentorChatPage> createState() => _MentorChatPageState();
}

class _MentorChatPageState extends State<MentorChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _convoStarted = false;
  bool _isTyping = false;
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  List<String> _quickReplies = <String>[];

  static const List<({String text, String reply, List<String> chips})> _starters =
      <({String text, String reply, List<String> chips})>[
    (
      text: "I'm exhausted today, what should I do?",
      reply:
          "Then today is a light day, and that still counts as showing up. One short walk is plenty. The steadier version of you is built on returning after the hard days, not on perfect ones. Want me to shrink today's plan to just the walk?",
      chips: <String>['Yes, lighten today', "I'll keep the full plan", 'Thanks, Sol'],
    ),
    (
      text: "Suggest a habit I'd actually keep",
      reply:
          "Since you already move most days, morning light would compound it. Ten minutes outside early sets your body clock, which feeds the sleep you're working on. Want to add it as a gentle daily prompt?",
      chips: <String>['Add morning light', 'Something calmer', 'Not now'],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  void _ensureConversation() {
    if (_convoStarted) {
      return;
    }
    setState(() => _convoStarted = true);
  }

  Future<void> _sendText([String? value]) async {
    final String trimmed = (value ?? _controller.text).trim();
    if (trimmed.isEmpty) {
      return;
    }
    _ensureConversation();
    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _controller.clear();
      _quickReplies = <String>[];
      _isTyping = true;
    });
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) {
      return;
    }
    ({String text, String reply, List<String> chips})? matchedStarter;
    for (final ({String text, String reply, List<String> chips}) starter in _starters) {
      if (starter.text == trimmed) {
        matchedStarter = starter;
        break;
      }
    }
    setState(() {
      _isTyping = false;
      if (matchedStarter != null) {
        _messages.add(_ChatMessage(text: matchedStarter.reply, isUser: false));
        _quickReplies = matchedStarter.chips;
      } else {
        _messages.add(
          const _ChatMessage(
            text: "I hear you. Tell me a little more and we'll work it out together.",
            isUser: false,
          ),
        );
      }
    });
    _scrollToBottom();
  }

  Future<void> _tapFollow(String chip) async {
    setState(() {
      _messages.add(_ChatMessage(text: chip, isUser: true));
      _quickReplies = <String>[];
      _isTyping = true;
    });
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) {
      return;
    }
    final String reply = switch (chip) {
      'Not now' => "No problem. I'm here whenever you want to pick it up.",
      'Yes, lighten today' => 'Lightened. Just the walk today, everything else can wait.',
      "I'll keep the full plan" => "Love it. I'll be right here if it starts to feel like too much.",
      'Thanks, Sol' => 'Anytime. Go easy on yourself today.',
      'Add morning light' =>
        "Added. I'll give you a gentle morning prompt, no pressure to be perfect.",
      'Something calmer' =>
        'How about two minutes of breathing after lunch? Small, and it settles the afternoon.',
      _ => 'Got it.',
    };
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    if (chip == 'Yes, lighten today') {
      showSolToast(context, title: 'Plan lightened', subtitle: 'Just the walk today');
    }
    if (chip == 'Add morning light') {
      showSolToast(
        context,
        title: 'Added to your plan',
        subtitle: 'Morning light · gentle daily prompt',
      );
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      safeAreaBottom: false,
      body: Column(
        children: <Widget>[
          _buildHeader(context),
          Expanded(
            child: _convoStarted ? _buildConversation() : _buildEmptyState(context),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_quickReplies.isNotEmpty)
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                itemCount: _quickReplies.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final String reply = _quickReplies[index];
                  return ActionChip(
                    label: Text(reply),
                    onPressed: () => _tapFollow(reply),
                    backgroundColor: SolColors.cream,
                    side: const BorderSide(color: SolColors.hair),
                  );
                },
              ),
            ),
          _buildComposer(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: SolColors.dawn.withValues(alpha: 0.82),
        border: const Border(bottom: BorderSide(color: SolColors.hair)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                foregroundColor: SolColors.coralText,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                '‹ Back',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SolMark(size: 28),
              const SizedBox(width: 8),
              Text(
                'Sol',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (_isTyping) ...<Widget>[
                const SizedBox(width: 6),
                Text(
                  'typing…',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SolColors.coralText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MemoryPage()),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: SolColors.cream,
                side: const BorderSide(color: SolColors.hair),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Text('💡', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        SolColors.gold.withValues(alpha: 0.38),
                        SolColors.coral.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                      stops: const <double>[0, 0.45, 0.7],
                    ),
                  ),
                ),
                const SolFlower(size: 80, fill: 0.75),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$_greeting, Noy',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'How can I help you today?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ..._starters.map((({String text, String reply, List<String> chips}) starter) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _sendText(starter.text),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SolColors.cocoa,
                    backgroundColor: SolColors.cream,
                    side: const BorderSide(color: SolColors.hair),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(starter.text, textAlign: TextAlign.left),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: _messages.length + 1 + (_isTyping ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: SolColors.cream,
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  border: Border.fromBorderSide(BorderSide(color: SolColors.hair)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: SolColors.clayDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        final int messageIndex = index - 1;
        if (messageIndex < _messages.length) {
          return _MessageBubble(message: _messages[messageIndex]);
        }
        return const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Sol is typing…',
            style: TextStyle(color: SolColors.clayDeep, fontSize: 13),
          ),
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: SolColors.dawn,
          border: Border(top: BorderSide(color: SolColors.hair)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
         /*   Opacity(
              opacity: 0.45,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.mic_none, color: SolColors.clayDeep),
                  ),
                  const Text(
                    'coming soon',
                    style: TextStyle(fontSize: 8.5, color: SolColors.clayDeep),
                  ),
                ],
              ),
            ),*/
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Message Sol…',
                  filled: true,
                  fillColor: SolColors.cream,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: SolColors.hair),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: SolColors.hair),
                  ),
                ),
                onSubmitted: _sendText,
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              onPressed: _controller.text.trim().isEmpty ? null : () => _sendText(),
              style: IconButton.styleFrom(
                backgroundColor: SolColors.cocoa,
                foregroundColor: SolColors.cream,
                disabledBackgroundColor: SolColors.cocoa.withValues(alpha: 0.4),
                disabledForegroundColor: SolColors.cream,
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final Alignment alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color background =
        message.isUser ? SolColors.cocoa : SolColors.cream;
    final Color foreground =
        message.isUser ? SolColors.cream : SolColors.cocoa;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(message.isUser ? 18 : 6),
              bottomRight: Radius.circular(message.isUser ? 6 : 18),
            ),
            border: message.isUser ? null : Border.all(color: SolColors.hair),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: foreground, height: 1.45, fontSize: 14.5),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}
