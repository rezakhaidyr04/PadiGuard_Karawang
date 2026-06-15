// File: lib/data/models/hama_model.dart
// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Model untuk hasil deteksi hama menggunakan AI
class HamaModel {
  final String id;
  final String sawahId;
  final String userId;
  final String pathFoto;
  final String urlFoto;
  final String namaHama;
  final double confidence; // 0.0 - 1.0
  final String tingkatRisiko; // RENDAH, SEDANG, TINGGI
  final String deskripsi;
  final List<String> solusi;
  final String pestsidaRekomendasi;
  final String dosasiPestisida;
  final String unitDosis; // kg, ml, liter, botol
  final String waktuAplikasi;
  final DateTime detectedAt;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? catatanResolusi;
  final DateTime createdAt;
  final DateTime updatedAt;

  HamaModel({
    required this.id,
    required this.sawahId,
    required this.userId,
    required this.pathFoto,
    required this.urlFoto,
    required this.namaHama,
    required this.confidence,
    required this.tingkatRisiko,
    required this.deskripsi,
    required this.solusi,
    required this.pestsidaRekomendasi,
    required this.dosasiPestisida,
    required this.unitDosis,
    required this.waktuAplikasi,
    required this.detectedAt,
    required this.resolved,
    this.resolvedAt,
    this.catatanResolusi,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Dari Firestore
  factory HamaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HamaModel(
      id: doc.id,
      sawahId: data['sawahId'] ?? '',
      userId: data['userId'] ?? '',
      pathFoto: data['pathFoto'] ?? '',
      urlFoto: data['urlFoto'] ?? '',
      namaHama: data['namaHama'] ?? 'Tidak Diketahui',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      tingkatRisiko: data['tingkatRisiko'] ?? 'SEDANG',
      deskripsi: data['deskripsi'] ?? '',
      solusi: List<String>.from(data['solusi'] ?? []),
      pestsidaRekomendasi: data['pestsidaRekomendasi'] ?? '',
      dosasiPestisida: data['dosasiPestisida'] ?? '',
      unitDosis: data['unitDosis'] ?? 'ml',
      waktuAplikasi: data['waktuAplikasi'] ?? '',
      detectedAt: (data['detectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolved: data['resolved'] ?? false,
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      catatanResolusi: data['catatanResolusi'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sawahId': sawahId,
      'userId': userId,
      'pathFoto': pathFoto,
      'urlFoto': urlFoto,
      'namaHama': namaHama,
      'confidence': confidence,
      'tingkatRisiko': tingkatRisiko,
      'deskripsi': deskripsi,
      'solusi': solusi,
      'pestsidaRekomendasi': pestsidaRekomendasi,
      'dosasiPestisida': dosasiPestisida,
      'unitDosis': unitDosis,
      'waktuAplikasi': waktuAplikasi,
      'detectedAt': Timestamp.fromDate(detectedAt),
      'resolved': resolved,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'catatanResolusi': catatanResolusi,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  HamaModel copyWith({
    String? id,
    String? sawahId,
    String? userId,
    String? pathFoto,
    String? urlFoto,
    String? namaHama,
    double? confidence,
    String? tingkatRisiko,
    String? deskripsi,
    List<String>? solusi,
    String? pestsidaRekomendasi,
    String? dosasiPestisida,
    String? unitDosis,
    String? waktuAplikasi,
    DateTime? detectedAt,
    bool? resolved,
    DateTime? resolvedAt,
    String? catatanResolusi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HamaModel(
      id: id ?? this.id,
      sawahId: sawahId ?? this.sawahId,
      userId: userId ?? this.userId,
      pathFoto: pathFoto ?? this.pathFoto,
      urlFoto: urlFoto ?? this.urlFoto,
      namaHama: namaHama ?? this.namaHama,
      confidence: confidence ?? this.confidence,
      tingkatRisiko: tingkatRisiko ?? this.tingkatRisiko,
      deskripsi: deskripsi ?? this.deskripsi,
      solusi: solusi ?? this.solusi,
      pestsidaRekomendasi: pestsidaRekomendasi ?? this.pestsidaRekomendasi,
      dosasiPestisida: dosasiPestisida ?? this.dosasiPestisida,
      unitDosis: unitDosis ?? this.unitDosis,
      waktuAplikasi: waktuAplikasi ?? this.waktuAplikasi,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      catatanResolusi: catatanResolusi ?? this.catatanResolusi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HamaModel(id: $id, namaHama: $namaHama, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
