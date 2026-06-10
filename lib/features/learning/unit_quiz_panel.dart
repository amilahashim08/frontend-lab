import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/quiz_question.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/glow_card.dart';

/// Inline topic quiz on the unit Quiz tab (matches current unit).
class UnitQuizPanel extends ConsumerStatefulWidget {
  const UnitQuizPanel({super.key, required this.unitId});

  final String unitId;

  @override
  ConsumerState<UnitQuizPanel> createState() => _UnitQuizPanelState();
}

class _UnitQuizPanelState extends ConsumerState<UnitQuizPanel> {
  int _index = 0;
  final Map<String, List<int>> _answers = {};
  bool _finished = false;
  int _score = 0;

  List<QuizQuestion> get _questions => ref
      .read(quizRepositoryProvider)
      .getQuestionsForUnit(widget.unitId);

  void _select(int optionIndex) {
    final q = _questions[_index];
    setState(() {
      if (q.type == QuestionType.multiChoice) {
        final current = List<int>.from(_answers[q.id] ?? []);
        if (current.contains(optionIndex)) {
          current.remove(optionIndex);
        } else {
          current.add(optionIndex);
        }
        _answers[q.id] = current;
      } else {
        _answers[q.id] = [optionIndex];
      }
    });
  }

  bool _isAnswerCorrect(QuizQuestion q) {
    final selected = _answers[q.id] ?? [];
    return selected.length == q.correctIndices.length &&
        selected.every(q.correctIndices.contains);
  }

  void _checkCurrent() {
    final q = _questions[_index];
    final selected = _answers[q.id] ?? [];
    if (selected.isEmpty) {
      AppToast.info(context, 'Select an answer first.');
      return;
    }
    final ok = _isAnswerCorrect(q);
    if (ok) {
      AppToast.success(
        context,
        q.explanation ?? 'Correct!',
      );
    } else {
      AppToast.error(
        context,
        q.explanation ?? 'Not quite — review the Learn tab and try again.',
      );
    }
  }

  void _nextOrFinish() {
    final q = _questions[_index];
    final selected = _answers[q.id] ?? [];
    if (selected.isEmpty) {
      AppToast.info(context, 'Select an answer before continuing.');
      return;
    }
    if (_isAnswerCorrect(q)) _score++;

    if (_index < _questions.length - 1) {
      setState(() => _index++);
      return;
    }

    final percent =
        ((_questions.isEmpty ? 0 : _score / _questions.length) * 100).round();
    final passed = percent >= AppConstants.defaultQuizPassingScore;
    setState(() => _finished = true);

    if (passed) {
      ref.read(userProgressProvider.notifier).recordQuizPass();
      ref.read(userProgressProvider.notifier).completeUnit(widget.unitId);
      AppToast.success(context, 'Quiz passed! $percent% — unit marked complete.');
    } else {
      AppToast.error(
        context,
        'Score $percent%. Need ${AppConstants.defaultQuizPassingScore}% to pass.',
      );
    }
  }

  void _reset() {
    setState(() {
      _index = 0;
      _answers.clear();
      _finished = false;
      _score = 0;
    });
    AppToast.info(context, 'Quiz reset.');
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: Text('No quiz questions for this unit yet.'));
    }

    if (_finished) {
      final percent = ((_score / _questions.length) * 100).round();
      final passed = percent >= AppConstants.defaultQuizPassingScore;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: GlowCard(
          glowColor: passed ? AppTheme.accent : AppTheme.error,
          child: Column(
            children: [
              Icon(
                passed ? Icons.emoji_events_outlined : Icons.refresh_rounded,
                size: 48,
                color: passed ? AppTheme.accent : AppTheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                passed ? 'Passed!' : 'Keep practicing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('$percent% ($_score / ${_questions.length})'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _reset, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];
    final selected = _answers[q.id] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Topic quiz · ${_index + 1} / ${_questions.length}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Questions match what you learned in this unit.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          GlowCard(child: Text(q.prompt, style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 12),
          ...q.options.asMap().entries.map((entry) {
            final i = entry.key;
            final isSelected = selected.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlowCard(
                glowColor: isSelected ? AppTheme.primary : null,
                onTap: () => _select(i),
                child: Text(entry.value),
              ),
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _checkCurrent,
                  child: const Text('Check'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _nextOrFinish,
            child: Text(
              _index < _questions.length - 1 ? 'Next question' : 'Finish quiz',
            ),
          ),
        ],
      ),
    );
  }
}
