import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/feature_badge.dart';
import '../../shared/widgets/glow_card.dart';

class InterviewSetupScreen extends StatefulWidget {
  const InterviewSetupScreen({super.key});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  String _trackId = AppConstants.interviewTracks.first.id;
  InterviewMode _mode = InterviewMode.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Mock Interview')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Flagship feature — AI asks, follows up, scores, suggests improvements.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          Text('Select track', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...AppConstants.interviewTracks.map((track) {
            final selected = _trackId == track.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlowCard(
                glowColor: selected ? AppTheme.secondary : null,
                onTap: () => setState(() => _trackId = track.id),
                child: Row(
                  children: [
                    Text(track.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(track.name),
                    const Spacer(),
                    if (selected)
                      const Icon(Icons.check, color: AppTheme.secondary),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _ModeTile(
            title: 'Text interview',
            selected: _mode == InterviewMode.text,
            phase: FeaturePhase.mvp,
            onTap: () => setState(() => _mode = InterviewMode.text),
          ),
          _ModeTile(
            title: 'Voice interview',
            selected: _mode == InterviewMode.voice,
            phase: FeaturePhase.phase2,
            enabled: false,
            onTap: () {},
          ),
          _ModeTile(
            title: 'Live coding',
            selected: _mode == InterviewMode.liveCoding,
            phase: FeaturePhase.phase2,
            enabled: false,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          GlowCard(
            onTap: () => context.push('/interview/bank'),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppTheme.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study 85 interview Q&A',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'JavaScript, React, CSS, Machine Coding, TypeScript — detailed answers + voice',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mode == InterviewMode.text
                ? () => context.push('/interview/session/$_trackId')
                : null,
            child: const Text('Start Mock Interview'),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.title,
    required this.selected,
    required this.phase,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final bool selected;
  final FeaturePhase phase;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: GlowCard(
          glowColor: selected ? AppTheme.primary : null,
          onTap: enabled ? onTap : null,
          child: Row(
            children: [
              Text(title),
              const Spacer(),
              FeatureBadge(phase: phase),
            ],
          ),
        ),
      ),
    );
  }
}
