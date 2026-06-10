import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../../data/models/weather_model.dart';

/// API Service for external API calls
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final logger = Logger();
  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        responseType: ResponseType.json,
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.d('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.d('API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.e('API Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Get current weather data from OpenWeatherMap
  Future<WeatherModel> getCurrentWeather({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? AppConstants.karawangLatitude;
      final lon = longitude ?? AppConstants.karawangLongitude;

      final response = await _dio.get(
        '${AppConstants.openWeatherMapBaseUrl}/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.openWeatherMapApiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final weatherData = WeatherModel.fromJson(response.data);
        logger.i('Weather data retrieved successfully');
        return weatherData;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      logger.e('Get weather error: $e');
      rethrow;
    }
  }

  /// Get weather forecast
  Future<List<WeatherModel>> getWeatherForecast({
    double? latitude,
    double? longitude,
    int days = 7,
  }) async {
    try {
      final lat = latitude ?? AppConstants.karawangLatitude;
      final lon = longitude ?? AppConstants.karawangLongitude;

      final response = await _dio.get(
        '${AppConstants.openWeatherMapBaseUrl}/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.openWeatherMapApiKey,
          'units': 'metric',
          'cnt': days * 8, // 8 forecasts per day
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['list'] ?? [];
        final forecasts = list
            .map((item) => WeatherModel.fromJson(item))
            .toList();
        logger.i('Weather forecast retrieved successfully');
        return forecasts;
      } else {
        throw Exception('Failed to fetch weather forecast');
      }
    } catch (e) {
      logger.e('Get forecast error: $e');
      rethrow;
    }
  }

  /// Get crop price data (mock implementation - replace with real API)
  Future<Map<String, dynamic>> getCropPrices() async {
    try {
      // Mock data - replace with real Hargapangan.id API
      final mockPriceData = {
        'gabah_kering': {
          'price': 5400,
          'currency': 'IDR/kg',
          'trend': 'up',
          'change': 2.5,
        },
        'beras': {
          'price': 12000,
          'currency': 'IDR/kg',
          'trend': 'stable',
          'change': 0.0,
        },
        'jagung': {
          'price': 3800,
          'currency': 'IDR/kg',
          'trend': 'down',
          'change': -1.2,
        },
      };
      logger.i('Crop prices retrieved successfully');
      return mockPriceData;
    } catch (e) {
      logger.e('Get crop prices error: $e');
      rethrow;
    }
  }

  /// Get fertilizer prices (mock implementation)
  Future<Map<String, dynamic>> getFertilizerPrices() async {
    try {
      // Mock data - replace with real API
      final mockFertilizerPrices = {
        'urea': {
          'price': 6500,
          'currency': 'IDR/kg',
          'available': true,
        },
        'npk_15_15_15': {
          'price': 8200,
          'currency': 'IDR/kg',
          'available': true,
        },
        'sp36': {
          'price': 7800,
          'currency': 'IDR/kg',
          'available': true,
        },
        'kcl': {
          'price': 8500,
          'currency': 'IDR/kg',
          'available': false,
        },
      };
      logger.i('Fertilizer prices retrieved successfully');
      return mockFertilizerPrices;
    } catch (e) {
      logger.e('Get fertilizer prices error: $e');
      rethrow;
    }
  }

  /// Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      logger.e('GET request error: $e');
      rethrow;
    }
  }

  /// Generic POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      logger.e('POST request error: $e');
      rethrow;
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      logger.e('PUT request error: $e');
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      logger.e('DELETE request error: $e');
      rethrow;
    }
  }
}
