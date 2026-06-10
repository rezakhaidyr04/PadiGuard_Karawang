// File: lib/core/services/ai_service.dart
import 'dart:io';
import 'package:logger/logger.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Disabled for FlutLab - use conditional imports for native
import 'package:image/image.dart' as img;

/// Service untuk AI/ML menggunakan TensorFlow Lite
/// Untuk deteksi hama padi dan tanaman
/// NOTE: TFLite model loading disabled on web/FlutLab - use API or mock responses instead
class AIService {
  static final AIService _instance = AIService._internal();
  // late Interpreter? _interpreter; // Disabled for FlutLab
  late List<String>? _labels;
  late Logger _logger;
  bool _isModelLoaded = false;

  factory AIService() {
    return _instance;
  }

  AIService._internal() {
    _logger = Logger();
  }

  /// Check apakah model sudah loaded
  bool get isModelLoaded => _isModelLoaded;

  /// Load model TensorFlow Lite dari assets
  /// Nama model harus: assets/models/hama_detection_model.tflite
  /// Nama labels harus: assets/models/labels.txt
  /// NOTE: Disabled on web/FlutLab - implement with API call instead
  Future<bool> loadModel() async {
    try {
      _logger.i('Model loading skipped on web platform');
      // Stub implementation for FlutLab
      _isModelLoaded = true;
      return true;
      
      // Original code below (for native platforms):
      // _logger.i('Loading TFLite model...');
      // _interpreter = await Interpreter.fromAsset(
      //   'models/hama_detection_model.tflite',
      //   options: InterpreterOptions()..threads = 4,
      // );
      // _logger.i('Model loaded successfully');
      // _isModelLoaded = true;
      // return true;
    } catch (e) {
      _logger.e('Error loading model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  /// Load labels dari file
  Future<bool> loadLabels() async {
    try {
      _logger.i('Loading labels...');
      
      // Hardcoded labels untuk penyakit padi
      _labels = [
        'Blast Fungus',
        'Brown Spot',
        'Leaf Scald',
        'Tungro',
        'Sheath Rot',
        'Bacterial Leaf Blight',
        'Healthy',
      ];

      _logger.i('Labels loaded: ${_labels?.length} diseases');
      return true;
    } catch (e) {
      _logger.e('Error loading labels: $e');
      return false;
    }
  }

  /// Deteksi hama dari file gambar
  /// Return: {namaHama: 'Blast Fungus', confidence: 0.92, risikoTingkat: 'TINGGI'}
  /// NOTE: On web/FlutLab, returns mock detection result
  Future<Map<String, dynamic>> detectDisease(File imageFile) async {
    if (!_isModelLoaded) {
      _logger.w('Model belum diload');
      return {'error': 'Model not loaded. Call loadModel() first'};
    }

    if (_labels == null || _labels!.isEmpty) {
      _logger.w('Labels belum diload');
      return {'error': 'Labels not loaded'};
    }

    try {
      _logger.i('Processing image: ${imageFile.path}');

      // For web/FlutLab: return mock detection
      // In production, call API endpoint instead
      final mockDetections = [
        {'name': 'Blast Fungus', 'confidence': 0.85},
        {'name': 'Brown Spot', 'confidence': 0.10},
        {'name': 'Leaf Scald', 'confidence': 0.03},
        {'name': 'Healthy', 'confidence': 0.02},
      ];

      final topDetection = mockDetections.first;
      final namaHama = topDetection['name'] as String;
      final confidence = topDetection['confidence'] as double;
      final tingkatRisiko = _getTingkatRisiko(namaHama, confidence);

      _logger.i(
        'Detection result: $namaHama (confidence: ${(confidence * 100).toStringAsFixed(1)}%)',
      );

      return {
        'success': true,
        'namaHama': namaHama,
        'confidence': confidence,
        'tingkatRisiko': tingkatRisiko,
        'allPredictions': mockDetections,
        'timestamp': DateTime.now().toString(),
      };
      
      // Original inference code below (for native platforms):
      // final imageData = imageFile.readAsBytesSync();
      // img.Image? image = img.decodeImage(imageData);
      // if (image == null) {
      //   return {'error': 'Failed to decode image'};
      // }
      // image = img.copyResize(image, width: 224, height: 224);
      // var input = _imageToByteList(image, 224, 224);
      // var output = List.filled(7, 0.0).reshape([1, 7]);
      // _interpreter?.run(input, output);
      // ... process output ...
    } catch (e) {
      _logger.e('Error detecting disease: $e');
      return {'error': 'Detection failed: $e'};
    }
  }

  /// Get tingkat risiko berdasarkan nama hama dan confidence
  String _getTingkatRisiko(String namaHama, double confidence) {
    // Hama dengan risiko tinggi
    if (namaHama == 'Blast Fungus' || namaHama == 'Tungro') {
      if (confidence > 0.7) return 'TINGGI';
      if (confidence > 0.4) return 'SEDANG';
    }

    // Hama dengan risiko sedang
    if (namaHama == 'Brown Spot' || namaHama == 'Bacterial Leaf Blight') {
      if (confidence > 0.6) return 'SEDANG';
      if (confidence > 0.3) return 'RENDAH';
    }

    // Sehat
    if (namaHama == 'Healthy') return 'RENDAH';

    // Default
    return confidence > 0.6 ? 'SEDANG' : 'RENDAH';
  }

  /// Original _imageToByteList method (for native platforms - commented out for FlutLab)
  /*
  List<List<List<List<double>>>> _imageToByteList(img.Image image, int inputSize, int outputSize) {
    var convertedBytes = <List<List<List<double>>>>[
      List<List<List<double>>>.filled(inputSize, [])
    ];
    final buffer = List<List<List<double>>>.filled(inputSize, []);

    for (int y = 0; y < inputSize; y++) {
      final line = List<List<double>>.filled(inputSize, []);
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixelSafe(x, y);
        line[x] = [
          ((pixel >> 16) & 0xFF).toDouble() / 255.0,
          ((pixel >> 8) & 0xFF).toDouble() / 255.0,
          (pixel & 0xFF).toDouble() / 255.0,
        ];
      }
      buffer[y] = line;
    }

    convertedBytes[0] = buffer;
    return convertedBytes;
  }
  */

  // _getAllPredictions removed (unused in FlutLab/mock path)

  /// Dispose model (stub for FlutLab)
  Future<void> dispose() async {
    try {
      // _interpreter?.close(); // Disabled for FlutLab
      _isModelLoaded = false;
      _logger.i('Model disposed');
    } catch (e) {
      _logger.e('Error disposing model: $e');
    }
  }

  /// Get informasi model (stub for FlutLab)
  String getModelInfo() {
    if (!_isModelLoaded) return 'Model not loaded';
    
    try {
      // Disabled for FlutLab - _interpreter not available
      // final inputShape = _interpreter?.getInputTensor(0).shape;
      // final outputShape = _interpreter?.getOutputTensor(0).shape;
      
      return '''
Model Info (Mock - FlutLab Mode):
- Status: Loaded ✓
- Input Shape: [1, 224, 224, 3]
- Output Shape: [1, 7]
- Labels: ${_labels?.length ?? 0} diseases
- Input Size: 224x224 RGB
''';
    } catch (e) {
      return 'Error getting model info: $e';
    }
  }
}

/// Helper class untuk hasil deteksi
class DetectionResult {
  final String namaHama;
  final double confidence;
  final String tingkatRisiko;
  final Map<String, double> allPredictions;
  final DateTime detectionTime;

  DetectionResult({
    required this.namaHama,
    required this.confidence,
    required this.tingkatRisiko,
    required this.allPredictions,
    required this.detectionTime,
  });

  @override
  String toString() {
    return 'DetectionResult(hama: $namaHama, confidence: ${(confidence * 100).toStringAsFixed(1)}%, risiko: $tingkatRisiko)';
  }

  /// Konversi ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'namaHama': namaHama,
      'confidence': confidence,
      'tingkatRisiko': tingkatRisiko,
      'allPredictions': allPredictions,
      'detectionTime': detectionTime.toIso8601String(),
    };
  }

  /// Dari JSON
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      namaHama: json['namaHama'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      tingkatRisiko: json['tingkatRisiko'] ?? 'SEDANG',
      allPredictions: Map<String, double>.from(json['allPredictions'] ?? {}),
      detectionTime: DateTime.parse(json['detectionTime'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Extension untuk Image processing
extension ImageExt on img.Image {
  /// Rotate gambar
  img.Image rotate(int angle) {
    return img.copyRotate(this, angle: angle);
  }

  /// Crop gambar
  img.Image crop(int x, int y, int width, int height) {
    return img.copyCrop(this, x: x, y: y, width: width, height: height);
  }
}
