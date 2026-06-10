// File: lib/data/models/sawah_model.dart
// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Model untuk Sawah (Lahan Pertanian)
/// Menyimpan data lengkap sawah untuk tracking kesehatan dan prediksi
class SawahModel {
  final String id;
  final String userId;
  final String nama;
  final double latitude;
  final double longitude;
  final double luasHektar;
  final String jenisTanaman; // padi, jagung, dll
  final DateTime tanggalTanam;
  final DateTime tanggalPanenExpected;
  final int umurTanamanHari;
  final double kelembaban; // 0-100 %
  final double ph; // 0-14
  final double temperatureCelsius;
  final String jenisAirTanah;
  final String ketersediaanAir; // lancar, kurang, buruk
  final String status; // tanam, tumbuh, matang, panen
  final String statusKesehatan; // sehat, risiko, sakit
  final int skorRisiko; // 0-100
  final List<String> idLogHama;
  final Map<String, dynamic>? dataKuacaTerakhir;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  SawahModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.luasHektar,
    required this.jenisTanaman,
    required this.tanggalTanam,
    required this.tanggalPanenExpected,
    required this.umurTanamanHari,
    required this.kelembaban,
    required this.ph,
    required this.temperatureCelsius,
    required this.jenisAirTanah,
    required this.ketersediaanAir,
    required this.status,
    required this.statusKesehatan,
    required this.skorRisiko,
    required this.idLogHama,
    this.dataKuacaTerakhir,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Buat SawahModel dari Firestore Document
  factory SawahModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SawahModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      nama: data['nama'] ?? 'Sawah Tanpa Nama',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      luasHektar: (data['luasHektar'] ?? 0.0).toDouble(),
      jenisTanaman: data['jenisTanaman'] ?? 'padi',
      tanggalTanam: (data['tanggalTanam'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tanggalPanenExpected:
          (data['tanggalPanenExpected'] as Timestamp?)?.toDate() ??
              DateTime.now().add(const Duration(days: 120)),
      umurTanamanHari: data['umurTanamanHari'] ?? 0,
      kelembaban: (data['kelembaban'] ?? 0.0).toDouble(),
      ph: (data['ph'] ?? 7.0).toDouble(),
      temperatureCelsius: (data['temperatureCelsius'] ?? 25.0).toDouble(),
      jenisAirTanah: data['jenisAirTanah'] ?? 'liat',
      ketersediaanAir: data['ketersediaanAir'] ?? 'lancar',
      status: data['status'] ?? 'tanam',
      statusKesehatan: data['statusKesehatan'] ?? 'sehat',
      skorRisiko: data['skorRisiko'] ?? 0,
      idLogHama: List<String>.from(data['idLogHama'] ?? []),
      dataKuacaTerakhir: data['dataKuacaTerakhir'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert SawahModel ke Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
      'luasHektar': luasHektar,
      'jenisTanaman': jenisTanaman,
      'tanggalTanam': Timestamp.fromDate(tanggalTanam),
      'tanggalPanenExpected': Timestamp.fromDate(tanggalPanenExpected),
      'umurTanamanHari': umurTanamanHari,
      'kelembaban': kelembaban,
      'ph': ph,
      'temperatureCelsius': temperatureCelsius,
      'jenisAirTanah': jenisAirTanah,
      'ketersediaanAir': ketersediaanAir,
      'status': status,
      'statusKesehatan': statusKesehatan,
      'skorRisiko': skorRisiko,
      'idLogHama': idLogHama,
      'dataKuacaTerakhir': dataKuacaTerakhir,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'isActive': isActive,
    };
  }

  /// Buat copy dengan field yang diupdate
  SawahModel copyWith({
    String? id,
    String? userId,
    String? nama,
    double? latitude,
    double? longitude,
    double? luasHektar,
    String? jenisTanaman,
    DateTime? tanggalTanam,
    DateTime? tanggalPanenExpected,
    int? umurTanamanHari,
    double? kelembaban,
    double? ph,
    double? temperatureCelsius,
    String? jenisAirTanah,
    String? ketersediaanAir,
    String? status,
    String? statusKesehatan,
    int? skorRisiko,
    List<String>? idLogHama,
    Map<String, dynamic>? dataKuacaTerakhir,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SawahModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      luasHektar: luasHektar ?? this.luasHektar,
      jenisTanaman: jenisTanaman ?? this.jenisTanaman,
      tanggalTanam: tanggalTanam ?? this.tanggalTanam,
      tanggalPanenExpected: tanggalPanenExpected ?? this.tanggalPanenExpected,
      umurTanamanHari: umurTanamanHari ?? this.umurTanamanHari,
      kelembaban: kelembaban ?? this.kelembaban,
      ph: ph ?? this.ph,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      jenisAirTanah: jenisAirTanah ?? this.jenisAirTanah,
      ketersediaanAir: ketersediaanAir ?? this.ketersediaanAir,
      status: status ?? this.status,
      statusKesehatan: statusKesehatan ?? this.statusKesehatan,
      skorRisiko: skorRisiko ?? this.skorRisiko,
      idLogHama: idLogHama ?? this.idLogHama,
      dataKuacaTerakhir: dataKuacaTerakhir ?? this.dataKuacaTerakhir,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'SawahModel(id: $id, nama: $nama, status: $status, kesehatan: $statusKesehatan)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawahModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
