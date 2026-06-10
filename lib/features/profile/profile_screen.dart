import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/xp_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(progress.rankTitle,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                XpProgressBar(
                  xp: progress.xp,
                  xpToNextLevel: progress.xpToNextLevel,
                  level: progress.level,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Stat('Units completed', '${progress.completedUnitIds.length}'),
          _Stat('Streak', '${progress.streak} days'),
          _Stat('Last interview', '${progress.lastInterviewScore}%'),
          const SizedBox(height: 24),
          Text('All topics (catalog)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...AppConstants.topicNames.entries.map(
            (e) => ListTile(
              title: Text(e.value),
              subtitle: Text(e.key),
              trailing: e.key == AppConstants.mvpTopicId
                  ? const Chip(label: Text('MVP'))
                  : const Chip(label: Text('Soon')),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }
}
