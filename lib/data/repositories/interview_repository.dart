import '../interview_category_constants.dart';
import '../interview_questions_data.dart';
import '../models/interview_question.dart';

/// Interview prep + mock AI scoring.
class InterviewRepository {
  static const Map<String, List<String>> _legacyQuestionsByTrack = {
    'INT-001': [
      'What is the virtual DOM and why does React use it?',
      'Explain the difference between props and state.',
      'What is JSX?',
    ],
    'INT-002': [
      'When would you use useMemo vs useCallback?',
      'How does React reconciliation work?',
      'Explain controlled vs uncontrolled components.',
    ],
    'INT-003': [
      'Describe the MERN request lifecycle for a login form.',
      'How do you structure Express middleware for JWT auth?',
      'When would you embed vs reference documents in MongoDB?',
    ],
    'INT-004': [
      'How would you design a scalable frontend architecture for 50+ engineers?',
      'Explain trade-offs between CSR, SSR, and SSG.',
      'How do you approach performance optimization on large React apps?',
    ],
  };

  static const Map<String, List<String>> _trackCategoryMix = {
    'INT-001': [
      InterviewCategories.javascript,
      InterviewCategories.css,
      InterviewCategories.react,
    ],
    'INT-002': [
      InterviewCategories.react,
      InterviewCategories.javascript,
    ],
    'INT-003': [
      InterviewCategories.javascript,
      InterviewCategories.react,
    ],
    'INT-004': [
      InterviewCategories.react,
      InterviewCategories.typescript,
      InterviewCategories.machineCoding,
    ],
  };

  List<InterviewCategoryInfo> getCategories() => InterviewCategories.all;

  List<InterviewQuestion> getQuestionsByCategory(String categoryId) {
    return List<InterviewQuestion>.from(
      interviewQuestionsByCategory[categoryId] ?? const [],
    );
  }

  InterviewQuestion? getQuestionById(String id) => interviewQuestionById(id);

  int getTotalQuestionCount() => totalInterviewQuestionCount;

  /// Mock session questions — sampled from the bank by track.
  List<String> getQuestionsForTrack(String trackId) {
    final categories = _trackCategoryMix[trackId];
    if (categories == null) {
      return List<String>.from(_legacyQuestionsByTrack['INT-001']!);
    }
    final pool = <InterviewQuestion>[];
    for (final cat in categories) {
      pool.addAll(getQuestionsByCategory(cat));
    }
    if (pool.isEmpty) {
      return List<String>.from(_legacyQuestionsByTrack[trackId] ?? _legacyQuestionsByTrack['INT-001']!);
    }
    pool.shuffle();
    return pool.take(5).map((q) => q.question).toList();
  }

  InterviewFeedback scoreAnswer({
    required String question,
    required String answer,
    InterviewQuestion? modelAnswer,
  }) {
    final wordCount = answer.trim().split(RegExp(r'\s+')).length;
    var score = 40;
    if (wordCount >= 20) score += 25;
    if (wordCount >= 50) score += 15;

    InterviewQuestion? model = modelAnswer;
    if (model == null) {
      for (final q in allInterviewQuestions()) {
        if (q.question == question) {
          model = q;
          break;
        }
      }
    }

    if (model != null) {
      final keywords = _extractKeywords(model.detailedAnswer);
      var hits = 0;
      final lower = answer.toLowerCase();
      for (final kw in keywords) {
        if (lower.contains(kw)) hits++;
      }
      score += (hits * 4).clamp(0, 20);
    } else {
      if (answer.toLowerCase().contains('react')) score += 10;
      if (answer.toLowerCase().contains('component') ||
          answer.toLowerCase().contains('state') ||
          answer.toLowerCase().contains('dom')) {
        score += 10;
      }
    }
    score = score.clamp(0, 100);

    final confidence = score >= 75
        ? 'High'
        : score >= 50
            ? 'Medium'
            : 'Low';

    return InterviewFeedback(
      score: score,
      confidence: confidence,
      feedback: score >= 70
          ? 'Solid answer. Consider adding a concrete example from a project.'
          : 'Expand your answer with definitions, trade-offs, and a short example.',
      improvedWording: model != null
          ? 'Model answer highlights: ${model.detailedAnswer.split('.').take(2).join('. ')}.'
          : 'Structure answers as: definition → why it matters → example → trade-off.',
      followUp: score >= 60
          ? 'Can you walk me through how that works under the hood?'
          : 'Let us start simpler — can you define the core concept in one sentence?',
      modelAnswer: model?.detailedAnswer,
    );
  }

  Set<String> _extractKeywords(String text) {
    final stop = {
      'the', 'and', 'for', 'with', 'that', 'this', 'from', 'when', 'are', 'use',
      'not', 'can', 'you', 'how', 'what', 'why', 'into', 'over', 'also', 'they',
    };
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 4 && !stop.contains(w))
        .take(12)
        .toSet();
  }
}

class InterviewFeedback {
  const InterviewFeedback({
    required this.score,
    required this.confidence,
    required this.feedback,
    required this.improvedWording,
    required this.followUp,
    this.modelAnswer,
  });

  final int score;
  final String confidence;
  final String feedback;
  final String improvedWording;
  final String followUp;
  final String? modelAnswer;
}
