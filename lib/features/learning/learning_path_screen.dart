import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/learning_unit.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glow_card.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(learningRepositoryProvider);
    final track = repo.getTrack(trackId);
    if (track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Path')),
        body: const Center(child: Text('Track not found')),
      );
    }

    final progress = ref.watch(userProgressProvider);
    final units = repo.getUnitsForTrack(
      trackId,
      completedIds: progress.completedUnitIds,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${track.icon} ${track.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/learn'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            track.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.touch_app, size: 16, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text(
                'Learn = animations · Activity = drag & drop · Quiz = test',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...units.map((unit) => _UnitTile(unit: unit)),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit});

  final LearningUnit unit;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (unit.status) {
      UnitStatus.completed => (Icons.check_circle, AppTheme.accent),
      UnitStatus.inProgress => (Icons.play_circle, AppTheme.primary),
      UnitStatus.locked => (Icons.lock, AppTheme.textSecondary),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        glowColor: unit.status == UnitStatus.inProgress ? AppTheme.primary : null,
        onTap: unit.status == UnitStatus.locked
            ? null
            : () => context.push('/learn/unit/${unit.id}'),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${unit.order}. ${unit.title}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    unit.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (unit.hasActivity)
              const Icon(Icons.touch_app, size: 16, color: AppTheme.accent),
            if (unit.hasQuiz) const Icon(Icons.quiz, size: 16),
          ],
        ),
      ),
    );
  }
}
