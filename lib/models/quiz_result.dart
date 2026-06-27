import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class QuizResult extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final int total;

  QuizResult({
    required this.date,
    required this.category,
    required this.score,
    required this.total,
  });

  String get isoDate => date.toIso8601String().split('T').first;

  int get percentage {
    if (total == 0) return 0;
    return ((score / total) * 100).round();
  }
}

class QuizResultAdapter extends TypeAdapter<QuizResult> {
  @override
  final int typeId = 0;

  @override
  QuizResult read(BinaryReader reader) {
    final date = DateTime.parse(reader.readString());
    final category = reader.readString();
    final score = reader.readInt();
    final total = reader.readInt();

    return QuizResult(
      date: date,
      category: category,
      score: score,
      total: total,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResult obj) {
    writer.writeString(obj.date.toIso8601String());
    writer.writeString(obj.category);
    writer.writeInt(obj.score);
    writer.writeInt(obj.total);
  }
}
