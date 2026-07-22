import 'package:flutter/material.dart';

void main() {
  runApp(const KidNationMobileGamesApp());
}

class KidNationMobileGamesApp extends StatelessWidget {
  const KidNationMobileGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidNation Ninja Runner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A7E1)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('KidNation Ninja Runner'),
        ),
      ),
    );
  }
}
