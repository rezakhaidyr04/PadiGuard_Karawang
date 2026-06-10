/// App-wide constants and configurations
class AppConstants {
  // App Info
  static const String appName = 'PadiGuard Karawang';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String openWeatherMapApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String openWeatherMapBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Karawang Location (Default)
  static const double karawangLatitude = -6.3027;
  static const double karawangLongitude = 107.3250;
  
  // AI/ML Settings
  static const String tfliteModelPath = 'assets/models/plant_disease_detection.tflite';
  static const double ailDetectionThreshold = 0.6;
  
  // Firebase Collections
  static const String firebaseUsersCollection = 'users';
  static const String firebaseFieldsCollection = 'fields';
  static const String firebaseDiseaseLogsCollection = 'disease_logs';
  static const String firebaseHarvestPredictionsCollection = 'harvest_predictions';
  static const String firebaseRecommendationsCollection = 'recommendations';
  static const String firebaseChatLogsCollection = 'chat_logs';
  
  // Disease Types
  static const List<String> diseaseTypes = [
    'Blast Fungus',
    'Brown Spot',
    'Leaf Scald',
    'Tungro',
    'Sheath Rot',
    'Bacterial Leaf Blight',
    'Healthy'
  ];
  
  // Fertilizer Types
  static const List<String> fertilizerTypes = [
    'Urea (N)',
    'NPK (15-15-15)',
    'SP-36 (Phosphate)',
    'KCl (Potassium)',
    'Organic Compost',
    'Calcium Nitrate'
  ];
  
  // Risk Levels
  static const String riskLevelLow = 'LOW';
  static const String riskLevelMedium = 'MEDIUM';
  static const String riskLevelHigh = 'HIGH';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 30);
}

/// UI Constants
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 40.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String firebaseError = 'Firebase error. Please try again.';
  static const String cameraPermissionDenied = 'Camera permission is required to detect plant diseases.';
  static const String locationPermissionDenied = 'Location permission is required to map your fields.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String modelNotLoaded = 'AI model failed to load. Please restart the app.';
}

/// Success Messages
class SuccessMessages {
  static const String fieldAdded = 'Field added successfully!';
  static const String diseaseDetected = 'Disease detection completed!';
  static const String recommendationGenerated = 'Recommendation generated successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
}
