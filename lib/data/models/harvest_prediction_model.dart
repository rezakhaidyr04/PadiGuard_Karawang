// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Harvest Prediction Model
class HarvestPredictionModel {
  final String id;
  final String fieldId;
  final String userId;
  final DateTime predictionDate;
  final DateTime estimatedHarvestDate;
  final int daysToHarvest;
  final double expectedYield; // in tons/hectare
  final double failureRisk; // 0-100 percentage
  final String failureReason;
  final String healthScore; // 'Excellent', 'Good', 'Fair', 'Poor'
  final String recommendation;
  final List<String> criticalFactors; // factors affecting harvest
  final bool isAccurate; // whether prediction was accurate after harvest
  final DateTime? actualHarvestDate;
  final double? actualYield;
  final DateTime createdAt;
  final DateTime updatedAt;

  HarvestPredictionModel({
    required this.id,
    required this.fieldId,
    required this.userId,
    required this.predictionDate,
    required this.estimatedHarvestDate,
    required this.daysToHarvest,
    required this.expectedYield,
    required this.failureRisk,
    required this.failureReason,
    required this.healthScore,
    required this.recommendation,
    required this.criticalFactors,
    this.isAccurate = false,
    this.actualHarvestDate,
    this.actualYield,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HarvestPredictionModel.fromJson(Map<String, dynamic> json) {
    return HarvestPredictionModel(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      userId: json['userId'] as String,
      predictionDate: (json['predictionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedHarvestDate: (json['estimatedHarvestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      daysToHarvest: json['daysToHarvest'] as int,
      expectedYield: (json['expectedYield'] as num).toDouble(),
      failureRisk: (json['failureRisk'] as num).toDouble(),
      failureReason: json['failureReason'] as String,
      healthScore: json['healthScore'] as String,
      recommendation: json['recommendation'] as String,
      criticalFactors: List<String>.from(json['criticalFactors'] as List? ?? []),
      isAccurate: json['isAccurate'] as bool? ?? false,
      actualHarvestDate: (json['actualHarvestDate'] as Timestamp?)?.toDate(),
      actualYield: (json['actualYield'] as num?)?.toDouble(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'userId': userId,
      'predictionDate': Timestamp.fromDate(predictionDate),
      'estimatedHarvestDate': Timestamp.fromDate(estimatedHarvestDate),
      'daysToHarvest': daysToHarvest,
      'expectedYield': expectedYield,
      'failureRisk': failureRisk,
      'failureReason': failureReason,
      'healthScore': healthScore,
      'recommendation': recommendation,
      'criticalFactors': criticalFactors,
      'isAccurate': isAccurate,
      'actualHarvestDate': actualHarvestDate != null ? Timestamp.fromDate(actualHarvestDate!) : null,
      'actualYield': actualYield,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HarvestPredictionModel copyWith({
    String? id,
    String? fieldId,
    String? userId,
    DateTime? predictionDate,
    DateTime? estimatedHarvestDate,
    int? daysToHarvest,
    double? expectedYield,
    double? failureRisk,
    String? failureReason,
    String? healthScore,
    String? recommendation,
    List<String>? criticalFactors,
    bool? isAccurate,
    DateTime? actualHarvestDate,
    double? actualYield,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HarvestPredictionModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      predictionDate: predictionDate ?? this.predictionDate,
      estimatedHarvestDate: estimatedHarvestDate ?? this.estimatedHarvestDate,
      daysToHarvest: daysToHarvest ?? this.daysToHarvest,
      expectedYield: expectedYield ?? this.expectedYield,
      failureRisk: failureRisk ?? this.failureRisk,
      failureReason: failureReason ?? this.failureReason,
      healthScore: healthScore ?? this.healthScore,
      recommendation: recommendation ?? this.recommendation,
      criticalFactors: criticalFactors ?? this.criticalFactors,
      isAccurate: isAccurate ?? this.isAccurate,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      actualYield: actualYield ?? this.actualYield,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
