import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite_item.dart';
import '../models/grammar_question.dart';

class FavoriteCategorySummary {
  final String category;
  final String title;
  final int count;

  const FavoriteCategorySummary({
    required this.category,
    required this.title,
    required this.count,
  });
}

class FavoriteService {
  static const String boxName = 'favoriteBox';

  static Future<void> initialize() async {
    await _box();
  }

  static ValueListenable<Box<dynamic>> listenable() {
    return Hive.box<dynamic>(boxName).listenable();
  }

  static int get count => _openBox.length;

  static List<FavoriteItem> get allFavorites {
    final items = _openBox.values
        .whereType<Map>()
        .map(
          (item) => FavoriteItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  static List<FavoriteCategorySummary> get categorySummaries {
    final grouped = <String, List<FavoriteItem>>{};

    for (final item in allFavorites) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final summaries = grouped.entries.map((entry) {
      return FavoriteCategorySummary(
        category: entry.key,
        title: entry.value.first.categoryTitle,
        count: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return List.unmodifiable(summaries);
  }

  static List<FavoriteItem> favoritesForCategory(String category) {
    return allFavorites
        .where((item) => item.category == category)
        .toList(growable: false);
  }

  static bool isFavorite({
    required GrammarQuestion question,
    required String category,
    required String exercise,
  }) {
    return _openBox.containsKey(
      FavoriteItem.createId(
        category: category,
        exercise: exercise,
        word: question.word,
        correctAnswer: question.correctAnswer,
      ),
    );
  }

  static Future<bool> toggleFavorite({
    required GrammarQuestion question,
    required String category,
    required String categoryTitle,
    required String exercise,
    required String exerciseTitle,
    required String instruction,
  }) async {
    final box = await _box();
    final id = FavoriteItem.createId(
      category: category,
      exercise: exercise,
      word: question.word,
      correctAnswer: question.correctAnswer,
    );

    if (box.containsKey(id)) {
      await box.delete(id);
      return false;
    }

    final item = FavoriteItem.fromQuestion(
      question: question,
      category: category,
      categoryTitle: categoryTitle,
      exercise: exercise,
      exerciseTitle: exerciseTitle,
      instruction: instruction,
    );

    await box.put(id, item.toJson());
    return true;
  }

  static Future<void> remove(String id) async {
    await _openBox.delete(id);
  }

  static Box<dynamic> get _openBox => Hive.box<dynamic>(boxName);

  static Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }
}
