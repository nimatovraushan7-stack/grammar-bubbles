import 'grammar_question.dart';

class QuizReviewItem {
  final GrammarQuestion question;
  final String? selectedAnswer;
  final bool isCorrect;

  const QuizReviewItem({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
  });
}
