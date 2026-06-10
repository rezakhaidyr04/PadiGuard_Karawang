// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Disease Detection Result Model
class DiseaseDetectionModel {
  final String id;
  final String fieldId;
  final String userId;
  final String imagePath;
  final String imageUrl;
  final String detectedDisease;
  final double confidence; // 0-1 (percentage)
  final String riskLevel; // 'LOW', 'MEDIUM', 'HIGH'
  final String description;
  final List<String> solutions;
  final String? recommendedPesticide;
  final double? pesticideDosage;
  final String? dosageUnit;
  final String? applicationTiming;
  final DateTime detectedAt;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  DiseaseDetectionModel({
    required this.id,
    required this.fieldId,
    required this.userId,
    required this.imagePath,
    required this.imageUrl,
    required this.detectedDisease,
    required this.confidence,
    required this.riskLevel,
    required this.description,
    required this.solutions,
    this.recommendedPesticide,
    this.pesticideDosage,
    this.dosageUnit,
    this.applicationTiming,
    required this.detectedAt,
    this.resolved = false,
    this.resolvedAt,
    this.resolutionNotes,
  });

  factory DiseaseDetectionModel.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionModel(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      userId: json['userId'] as String,
      imagePath: json['imagePath'] as String,
      imageUrl: json['imageUrl'] as String,
      detectedDisease: json['detectedDisease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      description: json['description'] as String,
      solutions: List<String>.from(json['solutions'] as List? ?? []),
      recommendedPesticide: json['recommendedPesticide'] as String?,
      pesticideDosage: (json['pesticideDosage'] as num?)?.toDouble(),
      dosageUnit: json['dosageUnit'] as String?,
      applicationTiming: json['applicationTiming'] as String?,
      detectedAt: (json['detectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolved: json['resolved'] as bool? ?? false,
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
      resolutionNotes: json['resolutionNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'userId': userId,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'detectedDisease': detectedDisease,
      'confidence': confidence,
      'riskLevel': riskLevel,
      'description': description,
      'solutions': solutions,
      'recommendedPesticide': recommendedPesticide,
      'pesticideDosage': pesticideDosage,
      'dosageUnit': dosageUnit,
      'applicationTiming': applicationTiming,
      'detectedAt': Timestamp.fromDate(detectedAt),
      'resolved': resolved,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolutionNotes': resolutionNotes,
    };
  }

  DiseaseDetectionModel copyWith({
    String? id,
    String? fieldId,
    String? userId,
    String? imagePath,
    String? imageUrl,
    String? detectedDisease,
    double? confidence,
    String? riskLevel,
    String? description,
    List<String>? solutions,
    String? recommendedPesticide,
    double? pesticideDosage,
    String? dosageUnit,
    String? applicationTiming,
    DateTime? detectedAt,
    bool? resolved,
    DateTime? resolvedAt,
    String? resolutionNotes,
  }) {
    return DiseaseDetectionModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      detectedDisease: detectedDisease ?? this.detectedDisease,
      confidence: confidence ?? this.confidence,
      riskLevel: riskLevel ?? this.riskLevel,
      description: description ?? this.description,
      solutions: solutions ?? this.solutions,
      recommendedPesticide: recommendedPesticide ?? this.recommendedPesticide,
      pesticideDosage: pesticideDosage ?? this.pesticideDosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      applicationTiming: applicationTiming ?? this.applicationTiming,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}
