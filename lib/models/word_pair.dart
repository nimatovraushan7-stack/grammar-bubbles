class WordPair {

  final String word;
  final String answer;

  WordPair({
    required this.word,
    required this.answer,
  });

  factory WordPair.fromJson(
    Map<String, dynamic> json,
  ) {
    return WordPair(
      word: json['word'],
      answer: json['answer'],
    );
  }
}