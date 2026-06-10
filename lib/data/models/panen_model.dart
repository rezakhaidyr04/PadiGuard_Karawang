// File: lib/data/models/panen_model.dart
// Firestore disabled for FlutLab - uncomment for production with Firebase
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Model untuk prediksi gagal panen
class PanenModel {
  final String id;
  final String sawahId;
  final String userId;
  final DateTime tanggalPrediksi;
  final DateTime estimasiTanggalPanen;
  final int hariHinggaPanen;
  final double estimasiHasilTon; // ton/hektar
  final int persentaseRisikoGagal; // 0-100
  final String penyebabRisiko;
  final List<String> faktorKritis;
  final String scoreKesehatan; // Sempurna, Baik, Cukup, Buruk
  final String rekomendasi;
  final bool isAccurate;
  final DateTime? tanggalPanenAktual;
  final double? hasilAktualTon;
  final DateTime createdAt;
  final DateTime updatedAt;

  PanenModel({
    required this.id,
    required this.sawahId,
    required this.userId,
    required this.tanggalPrediksi,
    required this.estimasiTanggalPanen,
    required this.hariHinggaPanen,
    required this.estimasiHasilTon,
    required this.persentaseRisikoGagal,
    required this.penyebabRisiko,
    required this.faktorKritis,
    required this.scoreKesehatan,
    required this.rekomendasi,
    required this.isAccurate,
    this.tanggalPanenAktual,
    this.hasilAktualTon,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Dari Firestore
  factory PanenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PanenModel(
      id: doc.id,
      sawahId: data['sawahId'] ?? '',
      userId: data['userId'] ?? '',
      tanggalPrediksi:
          (data['tanggalPrediksi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimasiTanggalPanen:
          (data['estimasiTanggalPanen'] as Timestamp?)?.toDate() ??
              DateTime.now().add(const Duration(days: 30)),
      hariHinggaPanen: data['hariHinggaPanen'] ?? 30,
      estimasiHasilTon: (data['estimasiHasilTon'] ?? 0.0).toDouble(),
      persentaseRisikoGagal: data['persentaseRisikoGagal'] ?? 0,
      penyebabRisiko: data['penyebabRisiko'] ?? '',
      faktorKritis: List<String>.from(data['faktorKritis'] ?? []),
      scoreKesehatan: data['scoreKesehatan'] ?? 'Baik',
      rekomendasi: data['rekomendasi'] ?? '',
      isAccurate: data['isAccurate'] ?? false,
      tanggalPanenAktual: (data['tanggalPanenAktual'] as Timestamp?)?.toDate(),
      hasilAktualTon: (data['hasilAktualTon'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sawahId': sawahId,
      'userId': userId,
      'tanggalPrediksi': Timestamp.fromDate(tanggalPrediksi),
      'estimasiTanggalPanen': Timestamp.fromDate(estimasiTanggalPanen),
      'hariHinggaPanen': hariHinggaPanen,
      'estimasiHasilTon': estimasiHasilTon,
      'persentaseRisikoGagal': persentaseRisikoGagal,
      'penyebabRisiko': penyebabRisiko,
      'faktorKritis': faktorKritis,
      'scoreKesehatan': scoreKesehatan,
      'rekomendasi': rekomendasi,
      'isAccurate': isAccurate,
      'tanggalPanenAktual':
          tanggalPanenAktual != null ? Timestamp.fromDate(tanggalPanenAktual!) : null,
      'hasilAktualTon': hasilAktualTon,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  PanenModel copyWith({
    String? id,
    String? sawahId,
    String? userId,
    DateTime? tanggalPrediksi,
    DateTime? estimasiTanggalPanen,
    int? hariHinggaPanen,
    double? estimasiHasilTon,
    int? persentaseRisikoGagal,
    String? penyebabRisiko,
    List<String>? faktorKritis,
    String? scoreKesehatan,
    String? rekomendasi,
    bool? isAccurate,
    DateTime? tanggalPanenAktual,
    double? hasilAktualTon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PanenModel(
      id: id ?? this.id,
      sawahId: sawahId ?? this.sawahId,
      userId: userId ?? this.userId,
      tanggalPrediksi: tanggalPrediksi ?? this.tanggalPrediksi,
      estimasiTanggalPanen: estimasiTanggalPanen ?? this.estimasiTanggalPanen,
      hariHinggaPanen: hariHinggaPanen ?? this.hariHinggaPanen,
      estimasiHasilTon: estimasiHasilTon ?? this.estimasiHasilTon,
      persentaseRisikoGagal: persentaseRisikoGagal ?? this.persentaseRisikoGagal,
      penyebabRisiko: penyebabRisiko ?? this.penyebabRisiko,
      faktorKritis: faktorKritis ?? this.faktorKritis,
      scoreKesehatan: scoreKesehatan ?? this.scoreKesehatan,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      isAccurate: isAccurate ?? this.isAccurate,
      tanggalPanenAktual: tanggalPanenAktual ?? this.tanggalPanenAktual,
      hasilAktualTon: hasilAktualTon ?? this.hasilAktualTon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PanenModel(id: $id, risikoGagal: $persentaseRisikoGagal%, hasilEsti: ${estimasiHasilTon}ton/ha)';
  }
}
