import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class InterviewSessionScreen extends ConsumerStatefulWidget {
  const InterviewSessionScreen({super.key, required this.trackId});

  final String trackId;

  @override
  ConsumerState<InterviewSessionScreen> createState() =>
      _InterviewSessionScreenState();
}

class _InterviewSessionScreenState
    extends ConsumerState<InterviewSessionScreen> {
  List<String>? _questions;
  int _qIndex = 0;
  int _totalScore = 0;
  int _answered = 0;
  final _answerController = TextEditingController();
  final List<Widget> _messages = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _questions = ref
        .read(interviewRepositoryProvider)
        .getQuestionsForTrack(widget.trackId);
    _addAiMessage(_questions!.first);
  }

  void _addAiMessage(String text) {
    _messages.add(_Bubble(isAi: true, text: text));
  }

  void _addUserMessage(String text) {
    _messages.add(_Bubble(isAi: false, text: text));
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _questions == null) return;

    final repo = ref.read(interviewRepositoryProvider);
    final feedback = repo.scoreAnswer(
      question: _questions![_qIndex],
      answer: answer,
    );

    _addUserMessage(answer);
    final modelBlock = feedback.modelAnswer != null
        ? '\n\nModel answer:\n${feedback.modelAnswer}\n'
        : '';
    _addAiMessage(
      'Score: ${feedback.score}% (${feedback.confidence} confidence)\n'
      '${feedback.feedback}\n\n'
      'Better wording: ${feedback.improvedWording}\n'
      '$modelBlock\n'
      'Follow-up: ${feedback.followUp}',
    );

    setState(() {
      _totalScore += feedback.score;
      _answered++;
      _answerController.clear();
    });

    if (_answered >= AppConstants.defaultInterviewQuestions ||
        _qIndex >= _questions!.length - 1) {
      _finishSession();
      return;
    }

    setState(() {
      _qIndex++;
      _addAiMessage(_questions![_qIndex]);
    });
  }

  Future<void> _finishSession() async {
    final avg = _answered == 0 ? 0 : (_totalScore / _answered).round();
    await ref.read(userProgressProvider.notifier).recordInterviewScore(avg);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Complete'),
        content: Text(
          'Average score: $avg%\n'
          'XP awarded: ${AppConstants.xpPerInterviewSession}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/dashboard');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview ${_qIndex + 1}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _messages[i],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submitAnswer,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.isAi, required this.text});

  final bool isAi;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAi ? AppTheme.surfaceElevated : AppTheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAi
                ? AppTheme.secondary.withValues(alpha: 0.3)
                : AppTheme.primary.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isAi ? AppTheme.textPrimary : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
