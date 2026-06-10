import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/feature_badge.dart';
import '../../shared/widgets/glow_card.dart';
import 'interview_bank_screen.dart';

/// Interview home: Question Bank (default tab) + Mock Interview.
class InterviewHubScreen extends ConsumerStatefulWidget {
  const InterviewHubScreen({super.key});

  @override
  ConsumerState<InterviewHubScreen> createState() => _InterviewHubScreenState();
}

class _InterviewHubScreenState extends ConsumerState<InterviewHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Prep'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Q&A Bank (85)'),
            Tab(icon: Icon(Icons.psychology_rounded), text: 'Mock Interview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          InterviewBankScreen(embed: true),
          _MockInterviewTab(),
        ],
      ),
    );
  }
}

class _MockInterviewTab extends StatefulWidget {
  const _MockInterviewTab();

  @override
  State<_MockInterviewTab> createState() => _MockInterviewTabState();
}

class _MockInterviewTabState extends State<_MockInterviewTab> {
  String _trackId = AppConstants.interviewTracks.first.id;
  InterviewMode _mode = InterviewMode.text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Practice answering out loud. AI scores your response and shows the model answer.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 16),
        _ModeTile(
          title: 'Text interview',
          selected: _mode == InterviewMode.text,
          phase: FeaturePhase.mvp,
          onTap: () => setState(() => _mode = InterviewMode.text),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _mode == InterviewMode.text
              ? () => context.push('/interview/session/$_trackId')
              : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Mock Interview'),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.title,
    required this.selected,
    required this.phase,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final FeaturePhase phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      glowColor: selected ? AppTheme.primary : null,
      onTap: onTap,
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          FeatureBadge(phase: phase),
        ],
      ),
    );
  }
}
