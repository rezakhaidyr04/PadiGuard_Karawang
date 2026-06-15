// File: lib/core/config/firebase_options.dart
// CATATAN: Ini adalah template. Gunakan: flutterfire configure
// untuk auto-generate file ini dengan kredensial Firebase Anda.

// Firebase disabled for FlutLab - uncomment for production
// import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Konfigurasi Firebase untuk Karawang AgroBrain (disabled for FlutLab)
class DefaultFirebaseOptions {
  // Firebase options disabled - uncomment when adding Firebase back
  /*
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZDY_Kz_XXXXXXXXXXXXX_YOUR_API_KEY_ANDROID',
    appId: '1:123456789012:android:abcdefghijklmnop1234',
    messagingSenderId: '123456789012',
    projectId: 'karawang-agrobrain',
    databaseURL: 'https://karawang-agrobrain.firebaseio.com',
    storageBucket: 'karawang-agrobrain.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZDY_Kz_XXXXXXXXXXXXX_YOUR_API_KEY_IOS',
    appId: '1:123456789012:ios:abcdefghijklmnop5678',
    messagingSenderId: '123456789012',
    projectId: 'karawang-agrobrain',
    databaseURL: 'https://karawang-agrobrain.firebaseio.com',
    storageBucket: 'karawang-agrobrain.appspot.com',
    iosBundleId: 'com.example.karawangagrobrain',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZDY_Kz_XXXXXXXXXXXXX_YOUR_API_KEY_WEB',
    appId: '1:123456789012:web:abcdefghijklmnop9012',
    messagingSenderId: '123456789012',
    projectId: 'karawang-agrobrain',
    authDomain: 'karawang-agrobrain.firebaseapp.com',
    storageBucket: 'karawang-agrobrain.appspot.com',
  );
  */
}

/// INSTRUKSI SETUP FIREBASE:
/// 
/// 1. Buat project di: https://console.firebase.google.com
/// 2. Tambahkan app (Android, iOS, Web)
/// 3. Download google-services.json (Android) & GoogleService-Info.plist (iOS)
/// 4. Letakkan di folder yang tepat:
///    - android/app/google-services.json
///    - ios/Runner/GoogleService-Info.plist
/// 5. Jalankan: flutterfire configure
/// 6. File ini akan di-update otomatis dengan kredensial benar
/// 7. Jangan commit kredensial ke Git! Tambahkan ke .gitignore:
///    - google-services.json
///    - GoogleService-Info.plist
///    - lib/core/config/firebase_options.dart (yang berisi API key asli)
