import 'package:flutter/material.dart';

import 'bubble_blast/ui/bubble_blast_screen.dart';
import 'ninja_go/ui/ninja_go_screen.dart';
import 'ninja_runner/ui/ninja_runner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1DF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'KidNation Games',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a quick KidNation game.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 24),
              _GameButton(
                title: 'Ninja Runner',
                subtitle: 'Run through the right answer gate.',
                color: const Color(0xFF00A7E1),
                onPressed: () => _open(context, const NinjaRunnerScreen()),
              ),
              const SizedBox(height: 12),
              _GameButton(
                title: 'Ninja Go',
                subtitle: 'Dodge obstacles in a three-lane reflex run.',
                color: const Color(0xFF16A34A),
                onPressed: () => _open(context, const NinjaGoScreen()),
              ),
              const SizedBox(height: 12),
              _GameButton(
                title: 'Bubble Blast',
                subtitle: 'Pop the bubble that matches the prompt.',
                color: const Color(0xFFFF7A59),
                onPressed: () => _open(context, const BubbleBlastScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(18),
        minimumSize: const Size.fromHeight(86),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 34),
        ],
      ),
    );
  }
}
