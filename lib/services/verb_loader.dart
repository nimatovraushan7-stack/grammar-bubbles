import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/verb_model.dart';

class VerbLoader {
  static const _assetPath = 'assets/data/verbs.json';
  static List<VerbModel>? _cache;

  static Future<List<VerbModel>> loadVerbs() async {
    final cachedVerbs = _cache;
    if (cachedVerbs != null) return cachedVerbs;

    final jsonString = await rootBundle.loadString(_assetPath);
    final jsonData = jsonDecode(jsonString);
    if (jsonData is! List) {
      throw const FormatException('verbs.json moet een JSON-lijst bevatten.');
    }

    final verbs = jsonData.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Elk item in verbs.json moet een JSON-object zijn.',
        );
      }
      return VerbModel.fromJson(item);
    }).toList(growable: false);

    _cache = List.unmodifiable(verbs);
    return _cache!;
  }
}
