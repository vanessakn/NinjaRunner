import 'package:flutter/material.dart';

import 'ninja_runner/ui/ninja_runner_screen.dart';

void main() {
  runApp(const KidNationMobileGamesApp());
}

class KidNationMobileGamesApp extends StatelessWidget {
  const KidNationMobileGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ninja Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A7E1)),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const NinjaRunnerScreen(),
    );
  }
}
