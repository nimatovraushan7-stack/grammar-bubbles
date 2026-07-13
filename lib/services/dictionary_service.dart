import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/dictionary_entry.dart';
import '../utils/dictionary_debug.dart';

class DictionaryService {
  static const String boxName = 'dictionaryBox';
  static const String _recentSearchesKey = 'recentSearches';
  static const int _recentSearchLimit = 10;
  static const List<String> _datasetPaths = [
    'assets/data/regular_verbs.json',
    'assets/data/irregular_verbs.json',
    'assets/data/separable_verbs.json',
    'assets/data/articles.json',
  ];

  static List<DictionaryEntry>? _entriesCache;
  static Future<List<DictionaryEntry>>? _entriesFuture;

  static Future<void> initialize() async {
    DictionaryDebug.log('DictionaryService', 'initialize start');
    await _box();
    DictionaryDebug.log('DictionaryService', 'initialize complete');
  }

  static Future<List<DictionaryEntry>> loadEntries() async {
    final cachedEntries = _entriesCache;
    if (cachedEntries != null) {
      DictionaryDebug.log(
        'DictionaryService',
        'loadEntries cache hit count=${cachedEntries.length}',
      );
      return cachedEntries;
    }

    final existingFuture = _entriesFuture;
    if (existingFuture != null) {
      DictionaryDebug.log('DictionaryService', 'loadEntries await existing');
      return existingFuture;
    }

    DictionaryDebug.log('DictionaryService', 'loadEntries create future');
    _entriesFuture = _loadEntries().catchError((Object error) {
      DictionaryDebug.log(
        'DictionaryService',
        'loadEntries future failed $error',
      );
      _entriesFuture = null;
      throw error;
    });
    return _entriesFuture!;
  }

  static List<DictionaryEntry> searchCached(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final entries = _entriesCache;

    DictionaryDebug.log(
      'DictionaryService',
      'searchCached query="$query" normalized="$normalizedQuery" '
          'cacheReady=${entries != null}',
    );

    if (normalizedQuery.isEmpty || entries == null) return const [];

    final rankedResults = <_RankedDictionaryEntry>[];

    for (final entry in entries) {
      final rank = _searchRank(entry, normalizedQuery);
      if (rank == null) continue;

      rankedResults.add(_RankedDictionaryEntry(entry: entry, rank: rank));
    }

    rankedResults.sort((a, b) {
      final rankComparison = a.rank.compareTo(b.rank);
      if (rankComparison != 0) return rankComparison;

      return a.entry.word.compareTo(b.entry.word);
    });

    final results = rankedResults
        .map((result) => result.entry)
        .take(60)
        .toList(growable: false);

    DictionaryDebug.log(
      'DictionaryService',
      'searchCached complete query="$normalizedQuery" '
          'matches=${rankedResults.length} returned=${results.length} '
          'first=${results.isEmpty ? '-' : results.first.word}',
    );

    return results;
  }

  static int? _searchRank(DictionaryEntry entry, String normalizedQuery) {
    final terms = _searchTerms(entry);

    if (terms.any((term) => term == normalizedQuery)) return 0;
    if (terms.any((term) => term.startsWith(normalizedQuery))) return 1;
    if (terms.any((term) => term.contains(normalizedQuery))) return 2;

    return null;
  }

  static List<String> _searchTerms(DictionaryEntry entry) {
    final terms = <String>{
      entry.word,
      if (entry.presentTense != null) entry.presentTense!,
      if (entry.pastTense != null) entry.pastTense!,
      if (entry.pastParticiple != null) entry.pastParticiple!,
      if (entry.presentParticiple != null) entry.presentParticiple!,
    };

    return terms
        .map((term) => term.trim().toLowerCase())
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
  }

  static Future<List<DictionaryEntry>> _loadEntries() async {
    DictionaryDebug.log('DictionaryService', '_loadEntries start');
    final entriesByKey = <String, DictionaryEntry>{};

    for (final assetPath in _datasetPaths) {
      DictionaryDebug.log(
        'DictionaryService',
        '_loadEntries asset start $assetPath',
      );
      final entries = await _loadEntriesFromAsset(assetPath);
      DictionaryDebug.log(
        'DictionaryService',
        '_loadEntries asset complete $assetPath count=${entries.length}',
      );
      for (final entry in entries) {
        entriesByKey.putIfAbsent(
          '${entry.type.name}:${entry.word.toLowerCase()}',
          () => entry,
        );
      }
    }

    final entries = entriesByKey.values.toList()
      ..sort((a, b) => a.word.compareTo(b.word));

    _entriesCache = List.unmodifiable(entries);
    DictionaryDebug.log(
      'DictionaryService',
      '_loadEntries complete unique=${_entriesCache!.length}',
    );
    return _entriesCache!;
  }

  static List<String> getRecentSearches() {
    final box = _boxSyncOrNull();
    if (box == null) {
      DictionaryDebug.log(
        'DictionaryService',
        'getRecentSearches skipped box not open',
      );
      return const [];
    }

    final searches = box.get(_recentSearchesKey);
    if (searches is List) {
      return List<String>.from(searches);
    }

    return const [];
  }

  static Future<void> saveRecentSearch(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    DictionaryDebug.log(
      'DictionaryService',
      'saveRecentSearch query="$query" normalized="$normalizedQuery"',
    );
    if (normalizedQuery.isEmpty) return;

    final box = await _box();
    final searches = getRecentSearches()
        .where((search) => search != normalizedQuery)
        .toList();

    searches.insert(0, normalizedQuery);
    await box.put(
      _recentSearchesKey,
      searches.take(_recentSearchLimit).toList(growable: false),
    );
    DictionaryDebug.log(
      'DictionaryService',
      'saveRecentSearch complete count=${searches.length}',
    );
  }

  static Future<List<DictionaryEntry>> _loadEntriesFromAsset(
    String assetPath,
  ) async {
    DictionaryDebug.log(
      'DictionaryService',
      '_loadEntriesFromAsset loadString $assetPath',
    );
    final jsonString = await rootBundle.loadString(assetPath);
    DictionaryDebug.log(
      'DictionaryService',
      '_loadEntriesFromAsset decode isolate $assetPath '
          'bytes=${jsonString.length}',
    );
    final jsonData = await Isolate.run(() => jsonDecode(jsonString));
    if (jsonData is! List) return const [];

    final entries = <DictionaryEntry>[];
    for (final item in jsonData) {
      if (item is! Map<String, dynamic>) continue;

      final word = _readOptionalString(item, 'word');
      if (word == null) continue;

      if (_isVerb(item)) {
        entries.add(
          DictionaryEntry(
            word: word,
            type: DictionaryEntryType.verb,
            source: assetPath,
            category: 'verbs',
            categoryTitle: 'Werkwoorden',
            presentTense: _readOptionalString(item, 'tegenwoordigeTijd'),
            pastTense: _readOptionalString(item, 'verledenTijd'),
            pastParticiple: _readOptionalString(item, 'voltooidDeelwoord'),
            presentParticiple: _readOptionalString(
              item,
              'tegenwoordigDeelwoord',
            ),
          ),
        );
        continue;
      }

      if (_isArticle(item)) {
        entries.add(
          DictionaryEntry(
            word: word,
            type: DictionaryEntryType.article,
            source: assetPath,
            category: 'articles',
            categoryTitle: 'Lidwoorden',
            article: _readOptionalString(item, 'article'),
            demonstrative: _readOptionalString(item, 'demonstrative'),
          ),
        );
        continue;
      }

      entries.add(
        DictionaryEntry(
          word: word,
          type: DictionaryEntryType.generic,
          source: assetPath,
          category: 'dictionary',
          categoryTitle: 'Dictionary',
        ),
      );
    }

    return entries;
  }

  static bool _isVerb(Map<String, dynamic> item) {
    return item.containsKey('verledenTijd') ||
        item.containsKey('voltooidDeelwoord') ||
        item.containsKey('tegenwoordigeTijd') ||
        item.containsKey('tegenwoordigDeelwoord');
  }

  static bool _isArticle(Map<String, dynamic> item) {
    return item.containsKey('article') || item.containsKey('demonstrative');
  }

  static String? _readOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static Box<dynamic>? _boxSyncOrNull() {
    if (!Hive.isBoxOpen(boxName)) return null;
    return Hive.box<dynamic>(boxName);
  }

  static Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }
}

class _RankedDictionaryEntry {
  final DictionaryEntry entry;
  final int rank;

  const _RankedDictionaryEntry({
    required this.entry,
    required this.rank,
  });
}
