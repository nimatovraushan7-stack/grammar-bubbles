class ArticleNoun {
  final String word;
  final String article;
  final String demonstrative;
  final String difficulty;
  final String level;

  const ArticleNoun({
    required this.word,
    required this.article,
    required this.demonstrative,
    required this.difficulty,
    required this.level,
  });

  factory ArticleNoun.fromJson(Map<String, dynamic> json) {
    return ArticleNoun(
      word: _readString(json, 'word'),
      article: _readString(json, 'article'),
      demonstrative: _readString(json, 'demonstrative'),
      difficulty: _readString(json, 'difficulty'),
      level: _readString(json, 'level'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Ongeldige of ontbrekende waarde voor "$key".');
    }
    return value;
  }
}
