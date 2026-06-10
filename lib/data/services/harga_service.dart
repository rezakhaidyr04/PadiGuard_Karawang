// File: lib/data/services/harga_service.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import '../models/harga_model.dart';

/// Service untuk prediksi harga gabah dan komoditas pertanian
/// Mengintegrasikan dengan API Hargapangan dan local predictions
class HargaService {
  static final HargaService _instance = HargaService._internal();
  late Dio _dio;
  late Logger _logger;

  final String _hargapanganUrl = 'https://api.hargapangan.id/v1';

  factory HargaService() {
    return _instance;
  }

  HargaService._internal() {
    _logger = Logger();
    _dio = Dio(BaseOptions(
      baseUrl: _hargapanganUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get harga gabah dari API atau local data
  /// Fallback ke data mock jika API tidak tersedia
  Future<HargaModel?> getHargaGabah({required String lokasi}) async {
    try {
      _logger.i('Fetching harga gabah for lokasi: $lokasi');

      // Try API dulu
      try {
        final response = await _dio.get('/commodities/paddy',
            queryParameters: {
              'location': lokasi,
              'unit': 'kg',
            });

        if (response.statusCode == 200) {
          final data = response.data;
          return _parseHargaResponse(data, 'Gabah Kering');
        }
      } catch (e) {
        _logger.w('API call failed, using mock data: $e');
      }

      // Fallback ke mock data
      return _getMockHargaGabah(lokasi);
    } catch (e) {
      _logger.e('Error getting harga gabah: $e');
      return null;
    }
  }

  /// Get harga beras
  Future<HargaModel?> getHargaBeras({required String lokasi}) async {
    try {
      _logger.i('Fetching harga beras for lokasi: $lokasi');

      try {
        final response = await _dio.get('/commodities/rice',
            queryParameters: {'location': lokasi});

        if (response.statusCode == 200) {
          final data = response.data;
          return _parseHargaResponse(data, 'Beras');
        }
      } catch (e) {
        _logger.w('API call failed, using mock data: $e');
      }

      return _getMockHargaBeras(lokasi);
    } catch (e) {
      _logger.e('Error getting harga beras: $e');
      return null;
    }
  }

  /// Get harga pupuk
  Future<List<HargaModel>> getHargaPupuk({required String lokasi}) async {
    try {
      _logger.i('Fetching harga pupuk for lokasi: $lokasi');

      final listHarga = <HargaModel>[
        _getMockHargaPupuk('Urea 46%', 3500, lokasi),
        _getMockHargaPupuk('NPK 15-15-15', 4000, lokasi),
        _getMockHargaPupuk('SP-36', 4500, lokasi),
        _getMockHargaPupuk('KCl 60%', 5000, lokasi),
        _getMockHargaPupuk('Kapur Pertanian', 500, lokasi),
      ];

      return listHarga;
    } catch (e) {
      _logger.e('Error getting harga pupuk: $e');
      return [];
    }
  }

  /// Prediksi harga minggu depan (simple moving average)
  /// Rata-rata + trend = forecast
  Future<Map<String, double>> predictHargaMingguDepan({
    required String komoditas,
    required double hargaSekarang,
    required List<double> hargaSebelumnya, // 7 hari terakhir
  }) async {
    try {
      _logger.i('Predicting price for: $komoditas');

      // Calculate trend
      double trend = 0;
      if (hargaSebelumnya.length > 1) {
        trend = (hargaSebelumnya.last - hargaSebelumnya.first) /
            hargaSebelumnya.length;
      }

      // Predict 7 hari
      final forecast = <String, double>{};

      for (int i = 1; i <= 7; i++) {
        final predictedPrice = hargaSekarang + (trend * i);
        forecast['hari_$i'] = predictedPrice.clamp(0, double.infinity);
      }

      _logger.i('Forecast: $forecast');
      return forecast;
    } catch (e) {
      _logger.e('Error predicting price: $e');
      return {};
    }
  }

  /// Get statistik harga historis
  Future<Map<String, dynamic>> getHargaStatistics({
    required String komoditas,
    required int jumlahHari,
  }) async {
    try {
      _logger.i('Getting price statistics for $komoditas (last $jumlahHari days)');

      // Mock data
      final prices = List.generate(jumlahHari, (i) {
        return 5000 + (i * 50) - (i * 30); // Simple trend
      }).cast<double>();

      return {
        'rataRata': prices.reduce((a, b) => a + b) / prices.length,
        'tertinggi': prices.reduce((a, b) => a > b ? a : b),
        'terendah': prices.reduce((a, b) => a < b ? a : b),
        'trend': prices.last > prices.first ? 'naik' : 'turun',
        'volatilitas': _calculateVolatility(prices),
      };
    } catch (e) {
      _logger.e('Error getting statistics: $e');
      return {};
    }
  }

  /// Parse response dari API Hargapangan
  HargaModel _parseHargaResponse(Map<String, dynamic> data, String komoditas) {
    final now = DateTime.now();

    return HargaModel(
      id: '${komoditas}_${now.millisecondsSinceEpoch}',
      namaKomoditas: komoditas,
      hargaSaatIni: (data['price'] ?? 5000).toDouble(),
      hargaSebelumnya: (data['price_prev_day'] ?? 4900).toDouble(),
      perubahanPersentase: (data['price_change_percent'] ?? 2.0).toDouble(),
      tren: _calculateTrend(data['price_change_percent'] ?? 0),
      lokasi: data['location'] ?? 'Karawang',
      tanggalUpdate: now,
      forecastHarga: {},
      sumber: 'Hargapangan API',
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Mock data: Harga Gabah
  HargaModel _getMockHargaGabah(String lokasi) {
    final now = DateTime.now();

    // Simulated forecast (next 7 days)
    final forecast = <String, double>{
      'day_1': 5450,
      'day_2': 5480,
      'day_3': 5420,
      'day_4': 5500,
      'day_5': 5550,
      'day_6': 5580,
      'day_7': 5620,
    };

    return HargaModel(
      id: 'gabah_mock_${now.millisecondsSinceEpoch}',
      namaKomoditas: 'Gabah Kering',
      hargaSaatIni: 5400,
      hargaSebelumnya: 5380,
      perubahanPersentase: 0.37,
      tren: 'naik',
      lokasi: lokasi,
      tanggalUpdate: now,
      forecastHarga: forecast,
      sumber: 'Mock Data',
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Mock data: Harga Beras
  HargaModel _getMockHargaBeras(String lokasi) {
    final now = DateTime.now();

    final forecast = <String, double>{
      'day_1': 12600,
      'day_2': 12650,
      'day_3': 12550,
      'day_4': 12700,
      'day_5': 12750,
      'day_6': 12800,
      'day_7': 12850,
    };

    return HargaModel(
      id: 'beras_mock_${now.millisecondsSinceEpoch}',
      namaKomoditas: 'Beras',
      hargaSaatIni: 12500,
      hargaSebelumnya: 12480,
      perubahanPersentase: 0.16,
      tren: 'naik',
      lokasi: lokasi,
      tanggalUpdate: now,
      forecastHarga: forecast,
      sumber: 'Mock Data',
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Mock data: Harga Pupuk
  HargaModel _getMockHargaPupuk(
    String jenisPupuk,
    double harga,
    String lokasi,
  ) {
    final now = DateTime.now();

    return HargaModel(
      id: '${jenisPupuk}_mock_${now.millisecondsSinceEpoch}',
      namaKomoditas: jenisPupuk,
      hargaSaatIni: harga.toDouble(),
      hargaSebelumnya: (harga * 0.98).toDouble(),
      perubahanPersentase: 2.0,
      tren: 'stabil',
      lokasi: lokasi,
      tanggalUpdate: now,
      forecastHarga: {},
      sumber: 'Mock Data',
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Tentukan trend dari persentase perubahan
  String _calculateTrend(double percentageChange) {
    if (percentageChange > 1) return 'naik';
    if (percentageChange < -1) return 'turun';
    return 'stabil';
  }

  /// Hitung volatilitas harga
  double _calculateVolatility(List<double> prices) {
    if (prices.length < 2) return 0;

    final mean = prices.reduce((a, b) => a + b) / prices.length;
    final variance = prices
            .map((p) => (p - mean) * (p - mean))
            .reduce((a, b) => a + b) /
        prices.length;

    return (math.pow(variance, 0.5)) / mean * 100; // Coefficient of variation
  }

  /// Get rekomendasi jual/beli
  String getRecommendation(HargaModel harga) {
    if (harga.perubahanPersentase > 5) {
      return '📈 Harga naik signifikan. Pertimbangkan untuk panen dan jual.';
    } else if (harga.perubahanPersentase < -5) {
      return '📉 Harga turun. Pertahankan stok jika memungkinkan.';
    } else if (harga.tren == 'naik') {
      return '⬆️ Trend naik. Indikasi baik untuk panen minggu depan.';
    } else if (harga.tren == 'turun') {
      return '⬇️ Trend turun. Tunggu signal pembelian pupuk.';
    }
    return '→ Harga stabil. Lanjutkan manajemen normal.';
  }
}
