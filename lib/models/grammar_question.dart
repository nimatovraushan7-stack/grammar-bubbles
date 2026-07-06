class GrammarQuestion {
  final String word;
  final String correctAnswer;
  final List<String> options;
  final String? instructionKey;

  GrammarQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
    this.instructionKey,
  });

  factory GrammarQuestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return GrammarQuestion(
      word: json['word'],
      correctAnswer: json['correctAnswer'],
      options: List<String>.from(
        json['options'],
      ),
      instructionKey: json['instructionKey'],
    );
  }
}
