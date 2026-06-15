// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// AI Recommendation Model (Pupuk, Pestisida, dll)
class RecommendationModel {
  final String id;
  final String fieldId;
  final String userId;
  final String type; // 'fertilizer', 'pesticide', 'irrigation', 'harvest'
  final String recommendationText;
  final String recommendedProduct; // e.g., "Urea 46%", "Dithane M-45"
  final double quantity; // in kg or liters
  final String unit; // 'kg', 'liter', 'bag'
  final String? applicationMethod; // 'spray', 'soil_application', 'foliar'
  final String? frequency; // 'once', 'weekly', 'biweekly'
  final int? daysFromNow; // recommended timing
  final String priority; // 'low', 'medium', 'high'
  final String reason; // why this recommendation
  final double? estimatedCost; // in Rupiah
  final bool implemented;
  final DateTime? implementedDate;
  final String? feedback; // user feedback after implementation
  final DateTime createdAt;
  final DateTime validUntil;

  RecommendationModel({
    required this.id,
    required this.fieldId,
    required this.userId,
    required this.type,
    required this.recommendationText,
    required this.recommendedProduct,
    required this.quantity,
    required this.unit,
    this.applicationMethod,
    this.frequency,
    this.daysFromNow,
    required this.priority,
    required this.reason,
    this.estimatedCost,
    this.implemented = false,
    this.implementedDate,
    this.feedback,
    required this.createdAt,
    required this.validUntil,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      recommendationText: json['recommendationText'] as String,
      recommendedProduct: json['recommendedProduct'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      applicationMethod: json['applicationMethod'] as String?,
      frequency: json['frequency'] as String?,
      daysFromNow: json['daysFromNow'] as int?,
      priority: json['priority'] as String,
      reason: json['reason'] as String,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      implemented: json['implemented'] as bool? ?? false,
      implementedDate: (json['implementedDate'] as Timestamp?)?.toDate(),
      feedback: json['feedback'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validUntil: (json['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'userId': userId,
      'type': type,
      'recommendationText': recommendationText,
      'recommendedProduct': recommendedProduct,
      'quantity': quantity,
      'unit': unit,
      'applicationMethod': applicationMethod,
      'frequency': frequency,
      'daysFromNow': daysFromNow,
      'priority': priority,
      'reason': reason,
      'estimatedCost': estimatedCost,
      'implemented': implemented,
      'implementedDate': implementedDate != null ? Timestamp.fromDate(implementedDate!) : null,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'validUntil': Timestamp.fromDate(validUntil),
    };
  }

  RecommendationModel copyWith({
    String? id,
    String? fieldId,
    String? userId,
    String? type,
    String? recommendationText,
    String? recommendedProduct,
    double? quantity,
    String? unit,
    String? applicationMethod,
    String? frequency,
    int? daysFromNow,
    String? priority,
    String? reason,
    double? estimatedCost,
    bool? implemented,
    DateTime? implementedDate,
    String? feedback,
    DateTime? createdAt,
    DateTime? validUntil,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      recommendationText: recommendationText ?? this.recommendationText,
      recommendedProduct: recommendedProduct ?? this.recommendedProduct,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      frequency: frequency ?? this.frequency,
      daysFromNow: daysFromNow ?? this.daysFromNow,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      implemented: implemented ?? this.implemented,
      implementedDate: implementedDate ?? this.implementedDate,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
