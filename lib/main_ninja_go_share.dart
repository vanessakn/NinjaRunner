import 'package:flutter/material.dart';

import 'ninja_go/ui/ninja_go_screen.dart';

void main() {
  runApp(const NinjaGoShareApp());
}

class NinjaGoShareApp extends StatelessWidget {
  const NinjaGoShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidNation Ninja Go',
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
      home: const NinjaGoScreen(),
    );
  }
}
