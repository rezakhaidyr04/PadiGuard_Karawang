import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weather_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

/// Current Weather Provider
final currentWeatherProvider = FutureProvider<WeatherModel?>((ref) async {
  try {
    final apiService = ApiService();
    final weather = await apiService.getCurrentWeather(
      latitude: AppConstants.karawangLatitude,
      longitude: AppConstants.karawangLongitude,
    );
    return weather;
  } catch (e) {
    return null;
  }
});

/// Weather Forecast Provider
final weatherForecastProvider = FutureProvider<List<WeatherModel>>((ref) async {
  try {
    final apiService = ApiService();
    final forecast = await apiService.getWeatherForecast(
      latitude: AppConstants.karawangLatitude,
      longitude: AppConstants.karawangLongitude,
      days: 7,
    );
    return forecast;
  } catch (e) {
    return [];
  }
});

/// Weather by Coordinates Provider
final weatherByCoordinatesProvider = 
    FutureProvider.family<WeatherModel?, (double, double)>((ref, coords) async {
  try {
    final apiService = ApiService();
    final weather = await apiService.getCurrentWeather(
      latitude: coords.$1,
      longitude: coords.$2,
    );
    return weather;
  } catch (e) {
    return null;
  }
});

/// Crop Prices Provider
final cropPricesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final apiService = ApiService();
    return await apiService.getCropPrices();
  } catch (e) {
    return {};
  }
});

/// Fertilizer Prices Provider
final fertilizerPricesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final apiService = ApiService();
    return await apiService.getFertilizerPrices();
  } catch (e) {
    return {};
  }
});

/// Refresh Weather Provider
final refreshWeatherProvider = StateProvider<int>((ref) => 0);

/// Auto-refresh Weather every 30 minutes
final autoRefreshWeatherProvider = FutureProvider<void>((ref) async {
  // TODO: Implement auto-refresh logic
});
