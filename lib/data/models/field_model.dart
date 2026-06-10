// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Field (Sawah) Model
class FieldModel {
  final String id;
  final String userId;
  final String name; // Field name (e.g., "Sawah Utama")
  final double latitude;
  final double longitude;
  final double areaSize; // in hectares
  final String cropType; // e.g., "Padi", "Jagung"
  final String plantingDate;
  final String? expectedHarvestDate;
  final int plantAge; // in days
  final double humidity; // percentage
  final double pH; // soil pH
  final double temperature; // in Celsius
  final String soilType; // e.g., "Clay", "Loam", "Sandy"
  final String waterAvailability; // e.g., "Adequate", "Low", "Excess"
  final String status; // 'planting', 'growing', 'mature', 'harvested'
  final String healthStatus; // 'healthy', 'at_risk', 'diseased'
  final double? riskScore; // 0-100
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> diseaseLogIds;
  final Map<String, dynamic>? lastWeatherData;

  FieldModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.areaSize,
    required this.cropType,
    required this.plantingDate,
    this.expectedHarvestDate,
    required this.plantAge,
    required this.humidity,
    required this.pH,
    required this.temperature,
    required this.soilType,
    required this.waterAvailability,
    required this.status,
    required this.healthStatus,
    this.riskScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.diseaseLogIds = const [],
    this.lastWeatherData,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      areaSize: (json['areaSize'] as num).toDouble(),
      cropType: json['cropType'] as String,
      plantingDate: json['plantingDate'] as String,
      expectedHarvestDate: json['expectedHarvestDate'] as String?,
      plantAge: json['plantAge'] as int,
      humidity: (json['humidity'] as num).toDouble(),
      pH: (json['pH'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      soilType: json['soilType'] as String,
      waterAvailability: json['waterAvailability'] as String,
      status: json['status'] as String,
      healthStatus: json['healthStatus'] as String,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diseaseLogIds: List<String>.from(json['diseaseLogIds'] as List? ?? []),
      lastWeatherData: json['lastWeatherData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'areaSize': areaSize,
      'cropType': cropType,
      'plantingDate': plantingDate,
      'expectedHarvestDate': expectedHarvestDate,
      'plantAge': plantAge,
      'humidity': humidity,
      'pH': pH,
      'temperature': temperature,
      'soilType': soilType,
      'waterAvailability': waterAvailability,
      'status': status,
      'healthStatus': healthStatus,
      'riskScore': riskScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'diseaseLogIds': diseaseLogIds,
      'lastWeatherData': lastWeatherData,
    };
  }

  FieldModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? latitude,
    double? longitude,
    double? areaSize,
    String? cropType,
    String? plantingDate,
    String? expectedHarvestDate,
    int? plantAge,
    double? humidity,
    double? pH,
    double? temperature,
    String? soilType,
    String? waterAvailability,
    String? status,
    String? healthStatus,
    double? riskScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? diseaseLogIds,
    Map<String, dynamic>? lastWeatherData,
  }) {
    return FieldModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaSize: areaSize ?? this.areaSize,
      cropType: cropType ?? this.cropType,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      plantAge: plantAge ?? this.plantAge,
      humidity: humidity ?? this.humidity,
      pH: pH ?? this.pH,
      temperature: temperature ?? this.temperature,
      soilType: soilType ?? this.soilType,
      waterAvailability: waterAvailability ?? this.waterAvailability,
      status: status ?? this.status,
      healthStatus: healthStatus ?? this.healthStatus,
      riskScore: riskScore ?? this.riskScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      diseaseLogIds: diseaseLogIds ?? this.diseaseLogIds,
      lastWeatherData: lastWeatherData ?? this.lastWeatherData,
    );
  }
}
