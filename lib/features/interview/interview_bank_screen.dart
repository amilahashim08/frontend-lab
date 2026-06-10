import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/interview_questions_data.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glow_card.dart';

/// Browse all interview question categories (85 questions).
class InterviewBankScreen extends ConsumerWidget {
  const InterviewBankScreen({super.key, this.embed = false});

  /// When true, rendered inside [InterviewHubScreen] tab (no own AppBar).
  final bool embed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(interviewRepositoryProvider);
    final categories = repo.getCategories();

    final body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${repo.getTotalQuestionCount()} most-asked frontend questions with detailed answers — '
            'JavaScript, React, CSS, Machine Coding, and TypeScript.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a category to study. Each question includes a full explanation and optional code example.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accent,
                ),
          ),
          const SizedBox(height: 20),
          ...categories.map((cat) {
            final count = interviewQuestionCountForCategory(cat.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlowCard(
                onTap: () => context.push('/interview/bank/${cat.id}'),
                child: Row(
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primary,
                              ),
                        ),
                        Text(
                          'questions',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            );
          }),
        ],
      );

    if (embed) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Question Bank')),
      body: body,
    );
  }
}
