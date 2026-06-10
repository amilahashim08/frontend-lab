enum QuestionType { singleChoice, multiChoice, trueFalse }

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndices,
    required this.type,
    this.explanation,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final List<int> correctIndices;
  final QuestionType type;
  final String? explanation;
}

class QuizResult {
  const QuizResult({
    required this.scorePercent,
    required this.passed,
    required this.correctCount,
    required this.totalCount,
  });

  final int scorePercent;
  final bool passed;
  final int correctCount;
  final int totalCount;
}
