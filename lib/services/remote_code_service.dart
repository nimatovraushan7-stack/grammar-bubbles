import 'dart:convert';
import 'hash_service.dart';

import 'package:http/http.dart' as http;

class RemoteCodeService {
  static const String codesUrl =
      'https://raw.githubusercontent.com/xzn024-byte/lol-config/main/codes.json';

  static Future<bool> isCodeValid(
  String inputCode,
) async {

  final trimmedCode =
      inputCode.trim();

  if (trimmedCode.isEmpty) {
    return false;
  }

  final enteredHash =
      HashService.generateHash(
        trimmedCode,
      );

    try {
      final response = await http.get(Uri.parse(codesUrl));
      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body);
      final codes = json['codes'];
      if (codes is! List) return false;

      for (final item in codes) {
        if (item is! Map<String, dynamic>) continue;

        final remoteHash = item['hash'];
final expires = item['expires'];

if (
  remoteHash is! String ||
  expires is! String
) {
  continue;
}

if (
  remoteHash != enteredHash
) {
  continue;
}

        final expiryDate = DateTime.tryParse(expires);
        if (expiryDate == null) return false;

        return DateTime.now().isBefore(expiryDate);
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
