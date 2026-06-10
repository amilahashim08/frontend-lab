import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Shared layout for interactive learning activities.
class ActivityShell extends StatelessWidget {
  const ActivityShell({
    super.key,
    required this.title,
    required this.instructions,
    required this.child,
    required this.poolSection,
    required this.onReset,
    required this.onCheck,
    this.canCheck = true,
  });

  final String title;
  final String instructions;
  final Widget child;
  final Widget poolSection;
  final VoidCallback onReset;
  final VoidCallback onCheck;
  final bool canCheck;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(instructions, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 20),
          poolSection,
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canCheck ? onCheck : null,
                  child: const Text('Check answer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
