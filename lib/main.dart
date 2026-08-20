import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/sol_theme.dart';
import 'core/Utils/StepCounter/step_counter.dart';
import 'core/Utils/StepCounter/step_repository.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

final StepRepository stepRepository = StepRepository();

final StepCounter stepCounter = StepCounter(
  repository: stepRepository,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const SolApp());
}

class SolApp extends StatelessWidget {
  const SolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sol',
      debugShowCheckedModeBanner: false,
      theme: SolTheme.buildLightTheme(),
      home: const OnboardingPage(),
    );
  }
}