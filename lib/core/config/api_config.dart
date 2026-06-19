import 'package:flutter/foundation.dart';

class ApiConfig {
  // Jika menggunakan Emulator Android, gunakan 10.0.2.2
  // Jika menggunakan Real Device, gunakan IP Address laptop Anda (misal: 192.168.1.15)
  // Jika menggunakan Flutter Web, gunakan localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000';
  }
}
