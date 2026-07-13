import 'package:flutter/foundation.dart';

class DictionaryDebug {
  static void log(String source, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[DictionaryDebug][$timestamp][$source] $message');
  }

  static void error(
    String source,
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint(
      '[DictionaryDebug][$timestamp][$source][ERROR]'
      '${context == null ? '' : ' $context'} $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}
