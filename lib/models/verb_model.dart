class VerbModel {
  final String word;
  final String verledenTijd;
  final String voltooidDeelwoord;
  final String tegenwoordigeTijd;
  final String tegenwoordigDeelwoord;
  final String level;

  const VerbModel({
    required this.word,
    required this.verledenTijd,
    required this.voltooidDeelwoord,
    required this.tegenwoordigeTijd,
    required this.tegenwoordigDeelwoord,
    this.level = 'A1',
  });

  factory VerbModel.fromJson(Map<String, dynamic> json) {
    return VerbModel(
      word: _readString(json, 'word'),
      verledenTijd: _readString(json, 'verledenTijd'),
      voltooidDeelwoord: _readString(json, 'voltooidDeelwoord'),
      tegenwoordigeTijd: _readString(json, 'tegenwoordigeTijd'),
      tegenwoordigDeelwoord: _readString(json, 'tegenwoordigDeelwoord'),
      level: _readOptionalString(json, 'level') ?? 'A1',
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Ongeldige of ontbrekende waarde voor "$key".');
    }
    return value;
  }

  static String? _readOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Ongeldige waarde voor "$key".');
    }
    return value;
  }
}
