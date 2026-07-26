import 'package:flutter/material.dart';

import '../../../../core/constants/sol_spacing.dart';
import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_ui.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        SolSpacing.pageHorizontal,
        12,
        SolSpacing.pageHorizontal,
        120,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Your journey',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            IconButton(
              onPressed: () {
                showSolToast(
                  context,
                  title: 'Ready to share',
                  subtitle: 'Your progress card was saved to Photos',
                );
              },
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SolColors.cream,
                  border: Border.all(color: SolColors.hair),
                ),
                child: const Icon(Icons.ios_share, size: 18, color: SolColors.coralText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SolCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text(
                    'Resting heart rate',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    '−4 bpm this month',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: SolColors.sageText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 66,
                child: CustomPaint(
                  painter: _HeartRateChartPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SolCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '23',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        Text(
                          'day streak',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SolColors.clayDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const <Widget>[
                      Text('Longest streak', style: TextStyle(color: SolColors.clayDeep)),
                      Text(
                        '23 days',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List<Widget>.generate(28, (int index) {
                  return Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: index < 23 ? SolColors.green : SolColors.cocoa.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 11),
              Text(
                'Every day since you started',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SolColors.sageText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SolCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text(
                    'Sleep is improving',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    'now past 7h ☀',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: SolColors.sageText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: CustomPaint(
                  painter: _SleepChartPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SolGradCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Building toward',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SolColors.cocoa.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Half marathon, 12 October',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text('11 weeks in', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('9 weeks to go', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: 0.55,
                  minHeight: 9,
                  backgroundColor: SolColors.cocoa.withValues(alpha: 0.16),
                  color: SolColors.cocoa.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Past halfway, and your long run has grown every month. No rush, the date is a horizon, not a test.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeartRateChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()
      ..color = SolColors.sage.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final Paint line = Paint()
      ..color = SolColors.sage
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path area = Path()
      ..moveTo(0, size.height * 0.26)
      ..lineTo(size.width * 0.17, size.height * 0.34)
      ..lineTo(size.width * 0.33, size.height * 0.29)
      ..lineTo(size.width * 0.5, size.height * 0.46)
      ..lineTo(size.width * 0.67, size.height * 0.54)
      ..lineTo(size.width * 0.83, size.height * 0.63)
      ..lineTo(size.width, size.height * 0.69)
      ..lineTo(size.width, size.height * 0.89)
      ..lineTo(0, size.height * 0.89)
      ..close();
    canvas.drawPath(area, fill);

    final Path stroke = Path()
      ..moveTo(0, size.height * 0.26)
      ..lineTo(size.width * 0.17, size.height * 0.34)
      ..lineTo(size.width * 0.33, size.height * 0.29)
      ..lineTo(size.width * 0.5, size.height * 0.46)
      ..lineTo(size.width * 0.67, size.height * 0.54)
      ..lineTo(size.width * 0.83, size.height * 0.63)
      ..lineTo(size.width, size.height * 0.69);
    canvas.drawPath(stroke, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SleepChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint target = Paint()
      ..color = SolColors.sage
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.29),
      Offset(size.width, size.height * 0.29),
      target,
    );

    final Paint fill = Paint()..color = SolColors.coral.withValues(alpha: 0.22);
    final Path area = Path()
      ..moveTo(0, size.height * 0.59)
      ..lineTo(size.width * 0.17, size.height * 0.67)
      ..lineTo(size.width * 0.33, size.height * 0.44)
      ..lineTo(size.width * 0.5, size.height * 0.52)
      ..lineTo(size.width * 0.67, size.height * 0.25)
      ..lineTo(size.width * 0.83, size.height * 0.19)
      ..lineTo(size.width, size.height * 0.23)
      ..lineTo(size.width, size.height * 0.85)
      ..lineTo(0, size.height * 0.85)
      ..close();
    canvas.drawPath(area, fill);

    final Paint line = Paint()
      ..color = SolColors.coral
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Path stroke = Path()
      ..moveTo(0, size.height * 0.59)
      ..lineTo(size.width * 0.17, size.height * 0.67)
      ..lineTo(size.width * 0.33, size.height * 0.44)
      ..lineTo(size.width * 0.5, size.height * 0.52)
      ..lineTo(size.width * 0.67, size.height * 0.25)
      ..lineTo(size.width * 0.83, size.height * 0.19)
      ..lineTo(size.width, size.height * 0.23);
    canvas.drawPath(stroke, line);

    const List<String> days = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (int i = 0; i < days.length; i++) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: const TextStyle(color: SolColors.clayDeep, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset((size.width / 6) * i - painter.width / 2, size.height * 0.92),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
