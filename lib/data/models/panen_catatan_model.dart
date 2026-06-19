// File: lib/data/models/panen_catatan_model.dart
// Model untuk catatan hasil panen nyata yang disimpan di MySQL

/// Model sederhana untuk catatan panen aktual (berbeda dari PanenModel
/// yang menyimpan prediksi. Model ini menyimpan catatan panen sungguhan.)
class PanenCatatanModel {
  final String id;
  final String sawahId;
  final String userId;
  final DateTime tanggalPanen;
  final double hasilPanenKg;
  final double hasilPerHektar;
  final double luasHektar;
  final String kualitasGabah; // GKP, GKG, Premium
  final double kadarAir;
  final int hargaJualPerKg;
  final int totalNilaiPanen;
  final String catatan;
  final String metodePanen; // manual, combine_harvester
  final DateTime createdAt;

  PanenCatatanModel({
    required this.id,
    required this.sawahId,
    required this.userId,
    required this.tanggalPanen,
    required this.hasilPanenKg,
    required this.hasilPerHektar,
    required this.luasHektar,
    required this.kualitasGabah,
    required this.kadarAir,
    required this.hargaJualPerKg,
    required this.totalNilaiPanen,
    required this.catatan,
    required this.metodePanen,
    required this.createdAt,
  });

  /// Parse dari response JSON MySQL
  factory PanenCatatanModel.fromJson(Map<String, dynamic> json) {
    return PanenCatatanModel(
      id: json['id'].toString(),
      sawahId: json['sawah_id'].toString(),
      userId: json['user_id'].toString(),
      tanggalPanen: DateTime.tryParse(json['tanggal_panen'] ?? '') ?? DateTime.now(),
      hasilPanenKg: double.tryParse(json['hasil_panen_kg'].toString()) ?? 0.0,
      hasilPerHektar: double.tryParse(json['hasil_per_hektar'].toString()) ?? 0.0,
      luasHektar: double.tryParse(json['luas_hektar'].toString()) ?? 1.0,
      kualitasGabah: json['kualitas_gabah'] ?? 'GKP',
      kadarAir: double.tryParse(json['kadar_air'].toString()) ?? 25.0,
      hargaJualPerKg: int.tryParse(json['harga_jual_per_kg'].toString()) ?? 6500,
      totalNilaiPanen: int.tryParse(json['total_nilai_panen'].toString()) ?? 0,
      catatan: json['catatan'] ?? '',
      metodePanen: json['metode_panen'] ?? 'manual',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sawah_id': sawahId,
      'tanggal_panen': tanggalPanen.toIso8601String().split('T')[0],
      'hasil_panen_kg': hasilPanenKg,
      'luas_hektar': luasHektar,
      'kualitas_gabah': kualitasGabah,
      'kadar_air': kadarAir,
      'harga_jual_per_kg': hargaJualPerKg,
      'catatan': catatan,
      'metode_panen': metodePanen,
    };
  }

  String get kualitasLabel {
    switch (kualitasGabah) {
      case 'GKG':
        return 'Gabah Kering Giling';
      case 'Premium':
        return 'Premium';
      default:
        return 'Gabah Kering Panen';
    }
  }

  String get totalNilaiFormatted {
    if (totalNilaiPanen >= 1000000) {
      return 'Rp ${(totalNilaiPanen / 1000000).toStringAsFixed(1)}jt';
    }
    return 'Rp ${totalNilaiPanen.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
