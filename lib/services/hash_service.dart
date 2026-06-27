import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  static String generateHash(
    String input,
  ) {
    return sha256
        .convert(
          utf8.encode(
            input.trim().toUpperCase(),
          ),
        )
        .toString();
  }
}