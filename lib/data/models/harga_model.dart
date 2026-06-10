// File: lib/data/models/harga_model.dart
// Firestore disabled for FlutLab - uncomment for production
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mocks.dart';

/// Model untuk data harga gabah dan komoditas pertanian
class HargaModel {
  final String id;
  final String namaKomoditas; // Gabah, Beras, Jagung, Kacang, dll
  final double hargaSaatIni; // Rp/kg
  final double hargaSebelumnya; // Rp/kg hari sebelumnya
  final double perubahanPersentase; // % naik/turun
  final String tren; // naik, turun, stabil
  final String lokasi; // Karawang, Jakarta, etc
  final DateTime tanggalUpdate;
  final Map<String, double> forecastHarga; // prediksi 7 hari
  final String sumber; // API Hargapangan, Manual, etc
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  HargaModel({
    required this.id,
    required this.namaKomoditas,
    required this.hargaSaatIni,
    required this.hargaSebelumnya,
    required this.perubahanPersentase,
    required this.tren,
    required this.lokasi,
    required this.tanggalUpdate,
    required this.forecastHarga,
    required this.sumber,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Dari Firestore
  factory HargaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HargaModel(
      id: doc.id,
      namaKomoditas: data['namaKomoditas'] ?? 'Gabah',
      hargaSaatIni: (data['hargaSaatIni'] ?? 0.0).toDouble(),
      hargaSebelumnya: (data['hargaSebelumnya'] ?? 0.0).toDouble(),
      perubahanPersentase: (data['perubahanPersentase'] ?? 0.0).toDouble(),
      tren: data['tren'] ?? 'stabil',
      lokasi: data['lokasi'] ?? 'Karawang',
      tanggalUpdate:
          (data['tanggalUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      forecastHarga: Map<String, double>.from(
        (data['forecastHarga'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
      sumber: data['sumber'] ?? 'Manual',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'namaKomoditas': namaKomoditas,
      'hargaSaatIni': hargaSaatIni,
      'hargaSebelumnya': hargaSebelumnya,
      'perubahanPersentase': perubahanPersentase,
      'tren': tren,
      'lokasi': lokasi,
      'tanggalUpdate': Timestamp.fromDate(tanggalUpdate),
      'forecastHarga': forecastHarga,
      'sumber': sumber,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  HargaModel copyWith({
    String? id,
    String? namaKomoditas,
    double? hargaSaatIni,
    double? hargaSebelumnya,
    double? perubahanPersentase,
    String? tren,
    String? lokasi,
    DateTime? tanggalUpdate,
    Map<String, double>? forecastHarga,
    String? sumber,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HargaModel(
      id: id ?? this.id,
      namaKomoditas: namaKomoditas ?? this.namaKomoditas,
      hargaSaatIni: hargaSaatIni ?? this.hargaSaatIni,
      hargaSebelumnya: hargaSebelumnya ?? this.hargaSebelumnya,
      perubahanPersentase: perubahanPersentase ?? this.perubahanPersentase,
      tren: tren ?? this.tren,
      lokasi: lokasi ?? this.lokasi,
      tanggalUpdate: tanggalUpdate ?? this.tanggalUpdate,
      forecastHarga: forecastHarga ?? this.forecastHarga,
      sumber: sumber ?? this.sumber,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate rata-rata harga forecast
  double getRataRataForecast() {
    if (forecastHarga.isEmpty) return hargaSaatIni;
    return forecastHarga.values.reduce((a, b) => a + b) / forecastHarga.length;
  }

  /// Get harga tertinggi dalam forecast
  double getHargaTertinggi() {
    if (forecastHarga.isEmpty) return hargaSaatIni;
    return forecastHarga.values.reduce((a, b) => a > b ? a : b);
  }

  /// Get harga terendah dalam forecast
  double getHargaTerendah() {
    if (forecastHarga.isEmpty) return hargaSaatIni;
    return forecastHarga.values.reduce((a, b) => a < b ? a : b);
  }

  @override
  String toString() {
    return 'HargaModel(id: $id, komoditas: $namaKomoditas, harga: Rp$hargaSaatIni, tren: $tren)';
  }
}
