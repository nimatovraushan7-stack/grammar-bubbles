class GrammarQuestion {
  final String word;
  final String correctAnswer;
  final List<String> options;
  final String? instructionKey;
  final String? category;
  final String? categoryTitle;
  final String? exercise;
  final String? exerciseTitle;

  GrammarQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
    this.instructionKey,
    this.category,
    this.categoryTitle,
    this.exercise,
    this.exerciseTitle,
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
      category: json['category'],
      categoryTitle: json['categoryTitle'],
      exercise: json['exercise'],
      exerciseTitle: json['exerciseTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'correctAnswer': correctAnswer,
      'options': options,
      if (instructionKey != null) 'instructionKey': instructionKey,
      if (category != null) 'category': category,
      if (categoryTitle != null) 'categoryTitle': categoryTitle,
      if (exercise != null) 'exercise': exercise,
      if (exerciseTitle != null) 'exerciseTitle': exerciseTitle,
    };
  }

  GrammarQuestion copyWith({
    String? instructionKey,
    String? category,
    String? categoryTitle,
    String? exercise,
    String? exerciseTitle,
  }) {
    return GrammarQuestion(
      word: word,
      correctAnswer: correctAnswer,
      options: options,
      instructionKey: instructionKey ?? this.instructionKey,
      category: category ?? this.category,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      exercise: exercise ?? this.exercise,
      exerciseTitle: exerciseTitle ?? this.exerciseTitle,
    );
  }
}
