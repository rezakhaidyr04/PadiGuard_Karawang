import 'package:flutter/foundation.dart';

class ApiConfig {
  // Tunnel publik aktif via localhost.run — bisa diakses dari HP manapun.
  // Jika tunnel mati, jalankan lagi: ssh -R 80:localhost:8000 nokey@localhost.run
  // Untuk Emulator: http://10.0.2.2:8000
  // Untuk Web    : http://localhost:8000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    // Public tunnel URL — aktif selama SSH berjalan
    return 'https://78f20675911928.lhr.life';
  }
}

