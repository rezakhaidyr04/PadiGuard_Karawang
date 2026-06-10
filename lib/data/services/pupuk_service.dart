// File: lib/data/services/pupuk_service.dart
import 'package:logger/logger.dart';
import '../models/pupuk_model.dart';

/// Service untuk rekomendasi pupuk berbasis aturan (Rule-Based Logic)
/// Nanti bisa diganti dengan ML model untuk akurasi lebih tinggi
class PupukService {
  static final PupukService _instance = PupukService._internal();
  late Logger _logger;

  factory PupukService() {
    return _instance;
  }

  PupukService._internal() {
    _logger = Logger();
  }

  /// Rekomendasi pupuk berdasarkan kondisi sawah
  /// Input: pH tanah, kelembaban, umur tanaman, hasil deteksi hama
  /// Output: List rekomendasi pupuk
  Future<List<PupukModel>> rekomendasikanPupuk({
    required String sawahId,
    required String userId,
    required double ph,
    required double kelembaban,
    required int umurTanamanHari,
    required String? namaHamaDeteksi,
    required double? confidenceHama,
  }) async {
    try {
      final recommendations = <PupukModel>[];
      final now = DateTime.now();

      _logger.i('Generating fertilizer recommendations for sawah: $sawahId');

      // Rule 1: pH rendah (asam) -> butuh kapur (CaCO3)
      if (ph < 6.0) {
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'Kapur Pertanian (CaCO3)',
            jumlahRekomendasi: _calculateDose(ph, 'kapur'),
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'sekali',
            jumlahHari: 3,
            prioritas: 'tinggi',
            alasan:
                'pH tanah rendah (${ph.toStringAsFixed(1)}). Aplikasikan kapur untuk meningkatkan pH tanah.',
            estimasiHarga:
                _calculatePrice('kapur', _calculateDose(ph, 'kapur')),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 14)),
            updatedAt: now,
          ),
        );
      }

      // Rule 2: pH tinggi (basa) -> butuh Sulfur
      if (ph > 8.0) {
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'Belerang (Sulfur)',
            jumlahRekomendasi: _calculateDose(ph, 'sulfur'),
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'sekali',
            jumlahHari: 3,
            prioritas: 'tinggi',
            alasan:
                'pH tanah tinggi (${ph.toStringAsFixed(1)}). Aplikasikan belerang untuk menurunkan pH.',
            estimasiHarga:
                _calculatePrice('sulfur', _calculateDose(ph, 'sulfur')),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 14)),
            updatedAt: now,
          ),
        );
      }

      // Rule 3: Kelembaban rendah -> butuh NPK untuk recovery
      if (kelembaban < 30) {
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'NPK 16-16-16',
            jumlahRekomendasi: _calculateDose(kelembaban, 'npk'),
            unit: 'kg/ha',
            metodeAplikasi: 'siram',
            frekuensi: 'mingguan',
            jumlahHari: 7,
            prioritas: 'tinggi',
            alasan:
                'Kelembaban tanah rendah (${kelembaban.toStringAsFixed(1)}%). Pupuk NPK membantu adaptasi terhadap stress kekeringan.',
            estimasiHarga:
                _calculatePrice('npk', _calculateDose(kelembaban, 'npk')),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 7)),
            updatedAt: now,
          ),
        );
      }

      // Rule 4: Umur tanaman -> Pupuk sesuai fase
      if (umurTanamanHari < 30) {
        // Fase pembibitan/awal tanam -> butuh banyak N
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'Urea 46%',
            jumlahRekomendasi: 100,
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'biweekly',
            jumlahHari: 14,
            prioritas: 'sedang',
            alasan:
                'Tanaman berumur $umurTanamanHari hari. Fase awal tanam membutuhkan nitrogen tinggi untuk pertumbuhan vegetatif.',
            estimasiHarga: _calculatePrice('urea', 100),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 10)),
            updatedAt: now,
          ),
        );
      } else if (umurTanamanHari >= 30 && umurTanamanHari < 60) {
        // Fase vegetatif aktif -> NPK seimbang
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'NPK 15-15-15',
            jumlahRekomendasi: 150,
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'biweekly',
            jumlahHari: 14,
            prioritas: 'sedang',
            alasan:
                'Tanaman berumur $umurTanamanHari hari. Fase vegetatif aktif membutuhkan NPK seimbang.',
            estimasiHarga: _calculatePrice('npk', 150),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 10)),
            updatedAt: now,
          ),
        );
      } else if (umurTanamanHari >= 60 && umurTanamanHari < 90) {
        // Fase berbunga/pembentukan malai -> tinggi K dan P
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'SP-36 (Superfosfat)',
            jumlahRekomendasi: 100,
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'sekali',
            jumlahHari: 3,
            prioritas: 'tinggi',
            alasan:
                'Tanaman berumur $umurTanamanHari hari. Fase berbunga membutuhkan fosfor tinggi untuk pembentukan malai.',
            estimasiHarga: _calculatePrice('sp36', 100),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 5)),
            updatedAt: now,
          ),
        );

        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'KCl 60% (Kalium Klorida)',
            jumlahRekomendasi: 80,
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'sekali',
            jumlahHari: 3,
            prioritas: 'tinggi',
            alasan:
                'Fase berbunga membutuhkan kalium untuk meningkatkan kualitas dan ketahanan padi.',
            estimasiHarga: _calculatePrice('kcl', 80),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 5)),
            updatedAt: now,
          ),
        );
      } else if (umurTanamanHari >= 90) {
        // Fase pematangan -> pupuk organik/mikronutrien
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'Pupuk Organik Kompos',
            jumlahRekomendasi: 2000,
            unit: 'kg/ha',
            metodeAplikasi: 'tabar',
            frekuensi: 'sekali',
            jumlahHari: 7,
            prioritas: 'rendah',
            alasan:
                'Tanaman berumur $umurTanamanHari hari. Fase pematangan butuh organik untuk kualitas hasil panen.',
            estimasiHarga: _calculatePrice('kompos', 2000),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 14)),
            updatedAt: now,
          ),
        );
      }

      // Rule 5: Hama terdeteksi -> tambah mikro nutrient
      if (namaHamaDeteksi != null && (confidenceHama ?? 0) > 0.6) {
        recommendations.add(
          PupukModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sawahId: sawahId,
            userId: userId,
            tanggalRekomendasi: now,
            jenisPupuk: 'Pupuk Mikro (Boron + Zinc)',
            jumlahRekomendasi: 20,
            unit: 'kg/ha',
            metodeAplikasi: 'foliage',
            frekuensi: 'mingguan',
            jumlahHari: 7,
            prioritas: 'sedang',
            alasan:
                'Terdeteksi kemungkinan penyakit $namaHamaDeteksi. Pupuk mikro meningkatkan imunitas tanaman.',
            estimasiHarga: _calculatePrice('mikro', 20),
            implemented: false,
            createdAt: now,
            validUntil: now.add(const Duration(days: 14)),
            updatedAt: now,
          ),
        );
      }

      _logger
          .i('Generated ${recommendations.length} fertilizer recommendations');
      return recommendations;
    } catch (e) {
      _logger.e('Error generating recommendations: $e');
      return [];
    }
  }

  /// Hitung dosis pupuk berdasarkan parameter
  double _calculateDose(double parameter, String jenisPupuk) {
    switch (jenisPupuk) {
      case 'kapur':
        // Dosis kapur = (target pH - pH sekarang) * 2 ton/ha
        return ((7.0 - parameter) * 2).clamp(1.0, 10.0);
      case 'sulfur':
        // Dosis sulfur = (pH sekarang - target pH) * 1 ton/ha
        return ((parameter - 7.0) * 1).clamp(0.5, 5.0);
      case 'npk':
        // Dosis NPK terbalik dengan kelembaban
        return 150 - (parameter / 100 * 50); // Range 100-150 kg/ha
      default:
        return 100;
    }
  }

  /// Hitung harga estimasi pupuk
  double _calculatePrice(String jenisPupuk, double jumlah) {
    const Map<String, double> hargaPerUnit = {
      'kapur': 500, // Rp/kg
      'sulfur': 1500,
      'urea': 3500,
      'npk': 4000,
      'sp36': 4500,
      'kcl': 5000,
      'kompos': 500,
      'mikro': 15000,
    };

    final harga = hargaPerUnit[jenisPupuk] ?? 5000;
    return harga * jumlah;
  }

  /// Get informasi lengkap pupuk
  Map<String, dynamic> getInfoPupuk(String jenisPupuk) {
    const Map<String, Map<String, dynamic>> infoPupuk = {
      'Urea 46%': {
        'nitrogen': 46,
        'deskripsi': 'Pupuk tunggal nitrogen tinggi',
        'manfaat': ['Pertumbuhan vegetatif', 'Warna daun hijau'],
        'toksisitas': 'Rendah jika dosis tepat',
      },
      'NPK 15-15-15': {
        'nitrogen': 15,
        'fosfor': 15,
        'kalium': 15,
        'deskripsi': 'Pupuk majemuk seimbang',
        'manfaat': [
          'Pertumbuhan seimbang',
          'Ketahanan tanaman',
          'Produksi optimal'
        ],
        'toksisitas': 'Rendah',
      },
      'SP-36': {
        'fosfor': 36,
        'deskripsi': 'Pupuk tunggal fosfor tinggi',
        'manfaat': [
          'Pembentukan akar',
          'Pembentukan buah/malai',
          'Ketahanan penyakit'
        ],
        'toksisitas': 'Rendah',
      },
      'KCl': {
        'kalium': 60,
        'deskripsi': 'Pupuk tunggal kalium tinggi',
        'manfaat': [
          'Ketahanan terhadap stress',
          'Kualitas hasil',
          'Penyerapan air'
        ],
        'toksisitas': 'Rendah',
      },
    };

    return infoPupuk[jenisPupuk] ??
        {
          'deskripsi': 'Informasi tidak tersedia',
          'manfaat': [],
        };
  }
}
