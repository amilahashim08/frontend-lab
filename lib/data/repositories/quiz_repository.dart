import '../models/quiz_question.dart';
import '../quiz_questions_data.dart';

class QuizRepository {
  List<QuizQuestion> getQuestionsForUnit(String unitId) {
    return quizQuestionsByUnit[unitId] ??
        const [
          QuizQuestion(
            id: 'fallback1',
            prompt: 'Complete the Learn and Activity tabs for this unit first.',
            options: ['OK', 'Skip', 'N/A', 'None'],
            correctIndices: [0],
            type: QuestionType.singleChoice,
          ),
        ];
  }
}
