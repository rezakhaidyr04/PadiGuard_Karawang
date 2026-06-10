// File: lib/data/services/panen_service.dart
// import 'package:cloud_functions/cloud_functions.dart'; // Disabled for web/FlutLab
import 'package:logger/logger.dart';
import '../models/panen_model.dart';

/// Service untuk prediksi gagal panen menggunakan Firebase Cloud Functions
/// NOTE: Cloud Functions disabled on web/FlutLab - using local prediction fallback
class PanenService {
  static final PanenService _instance = PanenService._internal();
  // late FirebaseFunctions _functions; // Disabled for web
  late Logger _logger;

  factory PanenService() {
    return _instance;
  }

  PanenService._internal() {
    // _functions = FirebaseFunctions.instance; // Disabled for web
    _logger = Logger();
  }

  /// Prediksi gagal panen menggunakan Firebase Function (or local fallback)
  /// Call Cloud Function: predictHarvestFailure
  /// Input: kelembaban, pH, umurTanaman, cuaca
  /// Output: risiko gagal, penyebab, rekomendasi
  /// NOTE: Uses local prediction on web/FlutLab
  Future<PanenModel?> predictHarvestFailure({
    required String sawahId,
    required String userId,
    required double kelembaban,
    required double ph,
    required int umurTanamanHari,
    required String cuacaSaat,
    required DateTime estimasiTanggalPanen,
    required double estimasiHasilTon,
  }) async {
    try {
      _logger
          .i('Calling prediction: predictHarvestFailure (local mode on web)');

      // Use local prediction instead of Firebase Function
      // In production, uncomment cloud function call:
      // final callable = _functions.httpsCallable('predictHarvestFailure');
      // final result = await callable.call({...});

      return await predictHarvestFailureLokal(
        sawahId: sawahId,
        userId: userId,
        kelembaban: kelembaban,
        ph: ph,
        umurTanamanHari: umurTanamanHari,
        estimasiTanggalPanen: estimasiTanggalPanen,
        estimasiHasilTon: estimasiHasilTon,
      );
    } catch (e) {
      _logger.e('Error calling prediction: $e');
      return null;
    }
  }

  /// Lokal prediksi (fallback jika Firebase Function tidak tersedia)
  Future<PanenModel> predictHarvestFailureLokal({
    required String sawahId,
    required String userId,
    required double kelembaban,
    required double ph,
    required int umurTanamanHari,
    required DateTime estimasiTanggalPanen,
    required double estimasiHasilTon,
  }) async {
    try {
      _logger.i('Predicting harvest failure (local mode)');

      int risikoPersentase = _calculateRiskPercentage(
        kelembaban,
        ph,
        umurTanamanHari,
      );

      String penyebab = _analyzeCause(kelembaban, ph, umurTanamanHari);
      List<String> faktorKritis = _getCriticalFactors(kelembaban, ph);
      String scoreKesehatan = _getHealthScore(risikoPersentase);

      return PanenModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sawahId: sawahId,
        userId: userId,
        tanggalPrediksi: DateTime.now(),
        estimasiTanggalPanen: estimasiTanggalPanen,
        hariHinggaPanen: estimasiTanggalPanen.difference(DateTime.now()).inDays,
        estimasiHasilTon: estimasiHasilTon * ((100 - risikoPersentase) / 100),
        persentaseRisikoGagal: risikoPersentase,
        penyebabRisiko: penyebab,
        faktorKritis: faktorKritis,
        scoreKesehatan: scoreKesehatan,
        rekomendasi: _generateRecommendation(penyebab),
        isAccurate: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error in local prediction: $e');
      rethrow;
    }
  }

  /// Hitung persentase risiko (0-100)
  int _calculateRiskPercentage(
    double kelembaban,
    double ph,
    int umurTanaman,
  ) {
    int risk = 0;

    // Kelembaban ideal: 50-80%
    if (kelembaban < 30 || kelembaban > 90) {
      risk += 40;
    } else if (kelembaban < 50 || kelembaban > 80) {
      risk += 20;
    }

    // pH ideal: 6.0-7.0
    if (ph < 5.0 || ph > 8.0) {
      risk += 30;
    } else if (ph < 6.0 || ph > 7.5) {
      risk += 15;
    }

    // Umur tanaman (buncis di usia kritis)
    if (umurTanaman >= 60 && umurTanaman <= 90) {
      // Fase berbunga - paling rawan
      risk += 20;
    } else if (umurTanaman > 100) {
      // Terlalu matang
      risk += 10;
    }

    return risk.clamp(0, 100);
  }

  /// Analisis penyebab risiko
  String _analyzeCause(double kelembaban, double ph, int umurTanaman) {
    final causes = <String>[];

    if (kelembaban < 30) {
      causes.add('Kelembaban rendah - risiko kekeringan');
    } else if (kelembaban > 85) {
      causes.add('Kelembaban tinggi - risiko busuk/jamur');
    }

    if (ph < 6.0) {
      causes.add('pH rendah (asam) - hara tidak tersedia');
    } else if (ph > 7.5) {
      causes.add('pH tinggi (basa) - unsur mikro terikat');
    }

    if (umurTanaman >= 75 && umurTanaman <= 85) {
      causes.add('Tanaman dalam fase berbunga - rawan penyakit');
    }

    return causes.isNotEmpty
        ? causes.join(', ')
        : 'Kondisi relatif normal, lanjutkan monitoring';
  }

  /// Get faktor-faktor kritis
  List<String> _getCriticalFactors(double kelembaban, double ph) {
    final factors = <String>[];

    factors
        .add('Kelembaban: ${kelembaban.toStringAsFixed(1)}% (ideal: 50-80%)');
    factors.add('pH Tanah: ${ph.toStringAsFixed(1)} (ideal: 6.0-7.0)');

    if (kelembaban < 40) {
      factors.add('⚠️ Risiko kekeringan - perlu irigasi');
    }
    if (ph < 5.5) {
      factors.add('⚠️ Tanah terlalu asam - perlu kapur');
    }

    return factors;
  }

  /// Get score kesehatan
  String _getHealthScore(int risikoPersentase) {
    if (risikoPersentase < 20) return 'Sempurna';
    if (risikoPersentase < 40) return 'Baik';
    if (risikoPersentase < 60) return 'Cukup';
    if (risikoPersentase < 80) return 'Buruk';
    return 'Sangat Buruk';
  }

  /// Generate rekomendasi
  String _generateRecommendation(String penyebab) {
    if (penyebab.contains('kekeringan')) {
      return 'Tingkatkan intensitas irigasi. Monitor kelembaban setiap hari.';
    }
    if (penyebab.contains('busuk')) {
      return 'Tingkatkan drainase. Aplikasikan fungisida jika perlu.';
    }
    if (penyebab.contains('asam')) {
      return 'Aplikasikan kapur pertanian untuk meningkatkan pH.';
    }
    if (penyebab.contains('berbunga')) {
      return 'Intensifkan pemantauan hama/penyakit. Siapkan pestisida.';
    }
    return 'Lanjutkan manajemen hama terpadu dan monitor kondisi sawah secara berkala.';
  }

  /// Get riwayat prediksi untuk sawah tertentu
  Future<List<PanenModel>> getRiwayatPrediksi(String sawahId) async {
    try {
      _logger.i('Fetching prediction history for sawah: $sawahId');
      // Implementasi nanti ketika Firestore integration selesai
      return [];
    } catch (e) {
      _logger.e('Error fetching prediction history: $e');
      return [];
    }
  }

  /// Hitung akurasi prediksi vs hasil aktual
  Future<double> calculateAccuracy(
    String predictionId,
    double actualYield,
  ) async {
    try {
      _logger.i('Calculating prediction accuracy for: $predictionId');

      // Query prediction dari Firestore
      // Bandingkan estimasi vs actual
      // Return akurasi

      return 0.0; // Placeholder
    } catch (e) {
      _logger.e('Error calculating accuracy: $e');
      return 0.0;
    }
  }
}
