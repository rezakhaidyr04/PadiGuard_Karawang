import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';

class ApiService {
  final Dio _dio;
  static const String _tokenKey = 'jwt_token';

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login.php', data: {
        'email': email,
        'password': password,
      });
      if (response.data['status'] == 'success' && response.data['token'] != null) {
        await saveToken(response.data['token']);
      }
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register.php', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      if (response.data['status'] == 'success' && response.data['token'] != null) {
        await saveToken(response.data['token']);
      }
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Sawah API ---
  
  Future<Map<String, dynamic>> getSawah() async {
    try {
      final response = await _dio.get('/sawah.php');
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addSawah(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/sawah.php', data: data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
