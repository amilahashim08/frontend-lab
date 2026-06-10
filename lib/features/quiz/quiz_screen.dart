import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../core/constants/app_constants.dart';

import '../../core/theme/app_theme.dart';

import '../../data/models/quiz_question.dart';

import '../../providers/app_providers.dart';

import '../../shared/widgets/app_toast.dart';

import '../../shared/widgets/glow_card.dart';



class QuizScreen extends ConsumerStatefulWidget {

  const QuizScreen({super.key, required this.unitId});



  final String unitId;



  @override

  ConsumerState<QuizScreen> createState() => _QuizScreenState();

}



class _QuizScreenState extends ConsumerState<QuizScreen> {

  int _index = 0;

  final Map<String, List<int>> _answers = {};

  bool _submitted = false;

  QuizResult? _result;



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



  void _checkCurrent() {

    final q = _questions[_index];

    final selected = _answers[q.id] ?? [];

    if (selected.isEmpty) {

      AppToast.info(context, 'Select an answer first.');

      return;

    }

    final match = selected.length == q.correctIndices.length &&

        selected.every(q.correctIndices.contains);

    if (match) {

      AppToast.success(context, q.explanation ?? 'Correct!');

    } else {

      AppToast.error(

        context,

        q.explanation ?? 'Incorrect — review the Learn tab.',

      );

    }

  }



  void _submitAll() {

    var correct = 0;

    for (final q in _questions) {

      final selected = _answers[q.id] ?? [];

      final match = selected.length == q.correctIndices.length &&

          selected.every(q.correctIndices.contains);

      if (match) correct++;

    }

    final percent = ((_questions.isEmpty ? 0 : correct / _questions.length) *

            100)

        .round();

    final passed = percent >= AppConstants.defaultQuizPassingScore;

    setState(() {

      _submitted = true;

      _result = QuizResult(

        scorePercent: percent,

        passed: passed,

        correctCount: correct,

        totalCount: _questions.length,

      );

    });

    if (passed) {

      ref.read(userProgressProvider.notifier).recordQuizPass();

      ref.read(userProgressProvider.notifier).completeUnit(widget.unitId);

      AppToast.success(context, 'Passed! $percent% on this topic.');

    } else {

      AppToast.error(

        context,

        'Score $percent%. Need ${AppConstants.defaultQuizPassingScore}% to pass.',

      );

    }

  }



  @override

  Widget build(BuildContext context) {

    if (_submitted && _result != null) {

      return _ResultView(

        result: _result!,

        onDone: () => context.pop(),

      );

    }



    final q = _questions[_index];

    final selected = _answers[q.id] ?? [];



    return Scaffold(

      appBar: AppBar(

        title: Text('Quiz ${_index + 1}/${_questions.length}'),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Text(

              'Topic quiz for this unit · passing ${AppConstants.defaultQuizPassingScore}%',

              style: Theme.of(context).textTheme.bodySmall?.copyWith(

                    color: AppTheme.textSecondary,

                  ),

            ),

            const SizedBox(height: 16),

            GlowCard(

              child: Text(q.prompt, style: Theme.of(context).textTheme.titleMedium),

            ),

            const SizedBox(height: 16),

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

            const Spacer(),

            Row(

              children: [

                Expanded(

                  child: OutlinedButton(

                    onPressed: selected.isEmpty ? null : _checkCurrent,

                    child: const Text('Check'),

                  ),

                ),

                const SizedBox(width: 12),

                Expanded(

                  flex: 2,

                  child: ElevatedButton(

                    onPressed: selected.isEmpty

                        ? null

                        : () {

                            if (_index < _questions.length - 1) {

                              setState(() => _index++);

                            } else {

                              _submitAll();

                            }

                          },

                    child: Text(

                      _index < _questions.length - 1

                          ? 'Next'

                          : 'Submit Quiz',

                    ),

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}



class _ResultView extends StatelessWidget {

  const _ResultView({required this.result, required this.onDone});



  final QuizResult result;

  final VoidCallback onDone;



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('Quiz Results')),

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: GlowCard(

            glowColor: result.passed ? AppTheme.accent : AppTheme.error,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(

                  result.passed ? 'Passed!' : 'Keep practicing',

                  style: Theme.of(context).textTheme.headlineSmall,

                ),

                const SizedBox(height: 16),

                Text('${result.scorePercent}%'),

                Text(

                  '${result.correctCount} / ${result.totalCount} correct',

                  style: Theme.of(context).textTheme.bodyMedium,

                ),

                const SizedBox(height: 24),

                ElevatedButton(onPressed: onDone, child: const Text('Done')),

              ],

            ),

          ),

        ),

      ),

    );

  }

}

