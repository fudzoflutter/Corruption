// lib/utils/tracking_code_generator.dart
import 'dart:math';

class TrackingCodeGenerator {
  static String generate() {
    final random = Random();
    final letter = String.fromCharCode(random.nextInt(26) + 65); // A-Z
    final numbers = (random.nextInt(9000) + 1000).toString(); // 1000-9999
    return '$letter$numbers'; // Natija: A1234
  }

  static bool isValid(String code) {
    return RegExp(r'^[A-Z]\d{4}$').hasMatch(code.toUpperCase());
  }
}