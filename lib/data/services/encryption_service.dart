import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String encryptContent(String content, String pin) {
    // Simple XOR encryption with hashed pin
    final hashedPin = _hashPin(pin);
    final contentBytes = utf8.encode(content);
    final keyBytes = utf8.encode(hashedPin);
    
    final encrypted = <int>[];
    for (int i = 0; i < contentBytes.length; i++) {
      encrypted.add(contentBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Encode(encrypted);
  }

  static String? decryptContent(String encryptedContent, String pin) {
    try {
      final hashedPin = _hashPin(pin);
      final encryptedBytes = base64Decode(encryptedContent);
      final keyBytes = utf8.encode(hashedPin);
      
      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      return null; // Invalid pin or corrupted data
    }
  }

  static bool verifyPin(String encryptedContent, String pin, String originalContent) {
    final decrypted = decryptContent(encryptedContent, pin);
    return decrypted == originalContent;
  }
}
