import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.xp,
    required this.xpToNextLevel,
    required this.level,
  });

  final int xp;
  final int xpToNextLevel;
  final int level;

  @override
  Widget build(BuildContext context) {
    final progress = xpToNextLevel == 0 ? 0.0 : xp / xpToNextLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level $level', style: Theme.of(context).textTheme.titleSmall),
            Text('$xp / $xpToNextLevel XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppTheme.surfaceElevated,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
