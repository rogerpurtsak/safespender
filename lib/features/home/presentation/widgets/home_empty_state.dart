import 'package:flutter/material.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    super.key,
    required this.onOpenSetup,
  });

  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDCE4E3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.savings_outlined,
                size: 42,
                color: Color(0xFF006763),
              ),
              const SizedBox(height: 16),
              Text(
                'Avaleht vajab setupi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sisesta esmalt sissetulek, püsikulud, puhver ja kategooriad. Siis saab avaleht sulle päris summary arvutada.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6A69),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onOpenSetup,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006763),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text('Ava setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
