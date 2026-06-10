import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glow_card.dart';

/// Choose a technology path: React, CSS, HTML, JavaScript.
class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.read(learningRepositoryProvider).getTracks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning paths'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pick a technology. Each path has animated lessons and drag-and-drop activities.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          ...tracks.map((track) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                glowColor: _trackColor(track.id),
                onTap: () => context.push('/learn/track/${track.id}'),
                child: Row(
                  children: [
                    Text(track.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${track.units.length} units · activities on every lesson',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color? _trackColor(String id) => switch (id) {
        'react' => AppTheme.primary,
        'css' => AppTheme.secondary,
        'html' => AppTheme.accent,
        'js' => const Color(0xFFFFB347),
        _ => null,
      };
}
