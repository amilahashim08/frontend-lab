import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/feature_badge.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/xp_progress_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlowCard(
            glowColor: AppTheme.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      progress.rankTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.local_fire_department,
                        color: AppTheme.accent, size: 20),
                    const SizedBox(width: 4),
                    Text('${progress.streak} day streak'),
                  ],
                ),
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
          _QuickStatRow(
            label: 'Interview score',
            value: '${progress.lastInterviewScore}%',
            icon: Icons.record_voice_over,
          ),
          const SizedBox(height: 8),
          _QuickStatRow(
            label: 'Weak topics',
            value: progress.weakTopicIds
                .map((id) => AppConstants.topicNames[id] ?? id)
                .join(', '),
            icon: Icons.trending_down,
          ),
          const SizedBox(height: 24),
          Text('Daily challenge', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GlowCard(
            onTap: () => context.push('/learn'),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    progress.dailyChallengeCompleted
                        ? 'Completed today — great work!'
                        : 'Complete one React quiz today (+50 XP)',
                  ),
                ),
                const FeatureBadge(phase: FeaturePhase.mvp),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Continue learning', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ActionTile(
            title: 'Learning paths',
            subtitle: 'React, CSS, HTML, JavaScript + activities',
            icon: Icons.school,
            onTap: () => context.push('/learn'),
            phase: FeaturePhase.mvp,
          ),
          _ActionTile(
            title: 'Interview Q&A Bank',
            subtitle: '85 questions — JS, React, CSS, TypeScript + voice',
            icon: Icons.menu_book_rounded,
            onTap: () => context.push('/interview/bank'),
            phase: FeaturePhase.mvp,
          ),
          _ActionTile(
            title: 'AI Mock Interview',
            subtitle: 'Practice answers — scored with model answers',
            icon: Icons.psychology,
            onTap: () => context.push('/interview'),
            phase: FeaturePhase.mvp,
          ),
          _ActionTile(
            title: 'Code Playground',
            subtitle: 'Write and save snippets',
            icon: Icons.terminal,
            onTap: () => context.push('/playground'),
            phase: FeaturePhase.mvp,
          ),
          _ActionTile(
            title: 'Visual Coding Challenges',
            subtitle: 'Fix broken apps',
            icon: Icons.bug_report,
            onTap: () => _showComingSoon(context, 'Phase 2'),
            phase: FeaturePhase.phase2,
          ),
          _ActionTile(
            title: 'Architecture Playground',
            subtitle: 'Drag/drop flows',
            icon: Icons.account_tree,
            onTap: () => _showComingSoon(context, 'Phase 3'),
            phase: FeaturePhase.phase3,
          ),
          _ActionTile(
            title: 'Community Battles',
            subtitle: 'Challenge friends',
            icon: Icons.groups,
            onTap: () => _showComingSoon(context, 'Phase 4'),
            phase: FeaturePhase.phase4,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.mic), label: 'Interview'),
          NavigationDestination(icon: Icon(Icons.code), label: 'Code'),
        ],
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              break;
            case 1:
              context.push('/learn');
            case 2:
              context.push('/interview');
            case 3:
              context.push('/playground');
          }
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String phase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Available in $phase — see REQUIREMENTS.md')),
    );
  }
}

class _QuickStatRow extends StatelessWidget {
  const _QuickStatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        )),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.phase,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final FeaturePhase phase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          )),
                ],
              ),
            ),
            FeatureBadge(phase: phase),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
