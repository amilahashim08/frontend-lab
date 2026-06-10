import 'interview_category_constants.dart';
import 'interview_questions/css_questions.dart';
import 'interview_questions/javascript_questions.dart';
import 'interview_questions/machine_coding_questions.dart';
import 'interview_questions/react_questions.dart';
import 'interview_questions/typescript_questions.dart';
import 'models/interview_question.dart';

/// Full frontend interview question bank (85 questions).
final Map<String, List<InterviewQuestion>> interviewQuestionsByCategory = {
  InterviewCategories.javascript: javascriptInterviewQuestions,
  InterviewCategories.react: reactInterviewQuestions,
  InterviewCategories.css: cssInterviewQuestions,
  InterviewCategories.machineCoding: machineCodingInterviewQuestions,
  InterviewCategories.typescript: typescriptInterviewQuestions,
};

List<InterviewQuestion> allInterviewQuestions() {
  return interviewQuestionsByCategory.values.expand((q) => q).toList();
}

InterviewQuestion? interviewQuestionById(String id) {
  for (final list in interviewQuestionsByCategory.values) {
    for (final q in list) {
      if (q.id == id) return q;
    }
  }
  return null;
}

int interviewQuestionCountForCategory(String categoryId) {
  return interviewQuestionsByCategory[categoryId]?.length ?? 0;
}

int get totalInterviewQuestionCount => allInterviewQuestions().length;
