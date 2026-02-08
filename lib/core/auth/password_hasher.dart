import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salt + SHA-256 password hashing for local SQLite auth.
/// For production APIs prefer bcrypt/argon2.
abstract final class PasswordHasher {
  static const int saltLength = 16;

  static String generateSalt() {
    final bytes = List<int>.generate(saltLength, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String password, String salt, String storedHash) {
    return hash(password, salt) == storedHash;
  }
}
