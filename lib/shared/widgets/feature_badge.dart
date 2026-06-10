import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Shows MVP vs Post-MVP label per REQUIREMENTS scope.
class FeatureBadge extends StatelessWidget {
  const FeatureBadge({super.key, required this.phase});

  final FeaturePhase phase;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phase) {
      FeaturePhase.mvp => ('MVP', AppTheme.accent),
      FeaturePhase.phase2 => ('Phase 2', AppTheme.primary),
      FeaturePhase.phase3 => ('Phase 3', AppTheme.secondary),
      FeaturePhase.phase4 => ('Phase 4', AppTheme.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
