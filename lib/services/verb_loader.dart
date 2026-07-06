import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/verb_model.dart';

class VerbLoader {
  static const _regularAssetPath = 'assets/data/regular_verbs.json';
  static const _irregularAssetPath = 'assets/data/irregular_verbs.json';
  static const _separableAssetPath = 'assets/data/separable_verbs.json';

  static List<VerbModel>? _regularCache;
  static List<VerbModel>? _irregularCache;
  static List<VerbModel>? _separableCache;

  static Future<List<VerbModel>> loadRegularVerbs() async {
    final cachedVerbs = _regularCache;
    if (cachedVerbs != null) return cachedVerbs;

    final verbs = await _loadVerbsFromAsset(_regularAssetPath);
    _regularCache = verbs;
    return verbs;
  }

  static Future<List<VerbModel>> loadIrregularVerbs() async {
    final cachedVerbs = _irregularCache;
    if (cachedVerbs != null) return cachedVerbs;

    final verbs = await _loadVerbsFromAsset(_irregularAssetPath);
    _irregularCache = verbs;
    return verbs;
  }

  static Future<List<VerbModel>> loadSeparableVerbs() async {
    final cachedVerbs = _separableCache;
    if (cachedVerbs != null) return cachedVerbs;

    final verbs = await _loadVerbsFromAsset(_separableAssetPath);
    _separableCache = verbs;
    return verbs;
  }

  static Future<List<VerbModel>> loadAllVerbs() async {
    final regularVerbs = await loadRegularVerbs();
    final irregularVerbs = await loadIrregularVerbs();
    final separableVerbs = await loadSeparableVerbs();

    return List.unmodifiable([
      ...regularVerbs,
      ...irregularVerbs,
      ...separableVerbs,
    ]);
  }

  static Future<List<VerbModel>> _loadVerbsFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = jsonDecode(jsonString);
    if (jsonData is! List) {
      throw FormatException('$assetPath moet een JSON-lijst bevatten.');
    }

    final verbs = jsonData.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException(
          'Elk item in $assetPath moet een JSON-object zijn.',
        );
      }
      return VerbModel.fromJson(item);
    }).toList(growable: false);

    return List.unmodifiable(verbs);
  }
}
