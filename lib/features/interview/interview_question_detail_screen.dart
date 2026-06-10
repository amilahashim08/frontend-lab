import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/interview_question.dart';
import '../../features/learning/learn/animated_speaker_button.dart';
import '../../features/learning/learn/learn_narration.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/glow_card.dart';

class InterviewQuestionDetailScreen extends ConsumerStatefulWidget {
  const InterviewQuestionDetailScreen({super.key, required this.questionId});

  final String questionId;

  @override
  ConsumerState<InterviewQuestionDetailScreen> createState() =>
      _InterviewQuestionDetailScreenState();
}

class _InterviewQuestionDetailScreenState
    extends ConsumerState<InterviewQuestionDetailScreen> {
  InterviewQuestion? _question;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _question ??= ref
        .read(interviewRepositoryProvider)
        .getQuestionById(widget.questionId);
  }

  @override
  void dispose() {
    LearnNarration.instance.stop();
    super.dispose();
  }

  Future<void> _listen() async {
    final q = _question;
    if (q == null) return;
    try {
      final ok = await LearnNarration.instance.toggleLesson(
        title: q.question,
        summary: q.detailedAnswer,
        bullets: q.tags,
        steps: q.codeExample != null ? ['See code example below'] : const [],
      );
      if (!ok && mounted) {
        AppToast.info(context, 'Voice unavailable: ${LearnNarration.instance.status}');
      }
    } catch (_) {
      if (mounted) AppToast.info(context, 'Could not play voice on this device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    if (q == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const Center(child: Text('Question not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Answer'),
        actions: [
          AnimatedSpeakerButton(onPressed: _listen, size: 20),
          ValueListenableBuilder<bool>(
            valueListenable: LearnNarration.instance.speaking,
            builder: (context, speaking, _) {
              if (!speaking) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: LearnNarration.instance.stop,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.question,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    AnimatedSpeakerButton(onPressed: _listen),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Tag(q.frequency, AppTheme.accent),
                    ...q.tags.map((t) => _Tag(t, AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Detailed answer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlowCard(
            child: Text(
              q.detailedAnswer,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
          ),
          if (q.codeExample != null) ...[
            const SizedBox(height: 16),
            Text('Code example', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            GlowCard(
              padding: const EdgeInsets.all(14),
              child: SelectableText(
                q.codeExample!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppTheme.accent,
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _listen,
            icon: const Icon(Icons.record_voice_over_rounded),
            label: const Text('Listen like Jarvis'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      visualDensity: VisualDensity.compact,
    );
  }
}
