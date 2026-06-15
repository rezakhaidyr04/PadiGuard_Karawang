// File: lib/data/models/pupuk_model.dart
// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Model untuk rekomendasi pupuk
class PupukModel {
  final String id;
  final String sawahId;
  final String userId;
  final DateTime tanggalRekomendasi;
  final String jenisPupuk; // Urea, NPK, SP-36, KCl, dll
  final double jumlahRekomendasi; // kg
  final String unit; // kg, liter, karung
  final String metodeAplikasi; // siram, tabar, foliage
  final String frekuensi; // sekali, mingguan, 2 mingguan
  final int jumlahHari; // aplikasi dalam X hari ke depan
  final String prioritas; // rendah, sedang, tinggi
  final String alasan; // penjelasan kenapa direkomendasikan
  final double estimasiHarga; // Rp
  final bool implemented;
  final DateTime? tanggalImplementasi;
  final String? feedback; // feedback dari petani
  final DateTime createdAt;
  final DateTime validUntil;
  final DateTime updatedAt;

  PupukModel({
    required this.id,
    required this.sawahId,
    required this.userId,
    required this.tanggalRekomendasi,
    required this.jenisPupuk,
    required this.jumlahRekomendasi,
    required this.unit,
    required this.metodeAplikasi,
    required this.frekuensi,
    required this.jumlahHari,
    required this.prioritas,
    required this.alasan,
    required this.estimasiHarga,
    required this.implemented,
    this.tanggalImplementasi,
    this.feedback,
    required this.createdAt,
    required this.validUntil,
    required this.updatedAt,
  });

  /// Dari Firestore
  factory PupukModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PupukModel(
      id: doc.id,
      sawahId: data['sawahId'] ?? '',
      userId: data['userId'] ?? '',
      tanggalRekomendasi:
          (data['tanggalRekomendasi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jenisPupuk: data['jenisPupuk'] ?? 'Urea',
      jumlahRekomendasi: (data['jumlahRekomendasi'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'kg',
      metodeAplikasi: data['metodeAplikasi'] ?? 'siram',
      frekuensi: data['frekuensi'] ?? 'mingguan',
      jumlahHari: data['jumlahHari'] ?? 7,
      prioritas: data['prioritas'] ?? 'sedang',
      alasan: data['alasan'] ?? '',
      estimasiHarga: (data['estimasiHarga'] ?? 0.0).toDouble(),
      implemented: data['implemented'] ?? false,
      tanggalImplementasi: (data['tanggalImplementasi'] as Timestamp?)?.toDate(),
      feedback: data['feedback'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sawahId': sawahId,
      'userId': userId,
      'tanggalRekomendasi': Timestamp.fromDate(tanggalRekomendasi),
      'jenisPupuk': jenisPupuk,
      'jumlahRekomendasi': jumlahRekomendasi,
      'unit': unit,
      'metodeAplikasi': metodeAplikasi,
      'frekuensi': frekuensi,
      'jumlahHari': jumlahHari,
      'prioritas': prioritas,
      'alasan': alasan,
      'estimasiHarga': estimasiHarga,
      'implemented': implemented,
      'tanggalImplementasi': tanggalImplementasi != null
          ? Timestamp.fromDate(tanggalImplementasi!)
          : null,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'validUntil': Timestamp.fromDate(validUntil),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  PupukModel copyWith({
    String? id,
    String? sawahId,
    String? userId,
    DateTime? tanggalRekomendasi,
    String? jenisPupuk,
    double? jumlahRekomendasi,
    String? unit,
    String? metodeAplikasi,
    String? frekuensi,
    int? jumlahHari,
    String? prioritas,
    String? alasan,
    double? estimasiHarga,
    bool? implemented,
    DateTime? tanggalImplementasi,
    String? feedback,
    DateTime? createdAt,
    DateTime? validUntil,
    DateTime? updatedAt,
  }) {
    return PupukModel(
      id: id ?? this.id,
      sawahId: sawahId ?? this.sawahId,
      userId: userId ?? this.userId,
      tanggalRekomendasi: tanggalRekomendasi ?? this.tanggalRekomendasi,
      jenisPupuk: jenisPupuk ?? this.jenisPupuk,
      jumlahRekomendasi: jumlahRekomendasi ?? this.jumlahRekomendasi,
      unit: unit ?? this.unit,
      metodeAplikasi: metodeAplikasi ?? this.metodeAplikasi,
      frekuensi: frekuensi ?? this.frekuensi,
      jumlahHari: jumlahHari ?? this.jumlahHari,
      prioritas: prioritas ?? this.prioritas,
      alasan: alasan ?? this.alasan,
      estimasiHarga: estimasiHarga ?? this.estimasiHarga,
      implemented: implemented ?? this.implemented,
      tanggalImplementasi: tanggalImplementasi ?? this.tanggalImplementasi,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PupukModel(id: $id, jenis: $jenisPupuk, jumlah: $jumlahRekomendasi$unit)';
  }
}
