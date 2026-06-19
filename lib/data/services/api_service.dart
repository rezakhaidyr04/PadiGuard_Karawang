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

  Future<Map<String, dynamic>> updateSawah(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/sawah.php', data: data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteSawah(String id) async {
    try {
      final response = await _dio.delete('/sawah.php', queryParameters: {'id': id});
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Hama API ---

  Future<Map<String, dynamic>> getHama({String? sawahId}) async {
    try {
      final params = sawahId != null ? {'sawah_id': sawahId} : null;
      final response = await _dio.get('/hama.php', queryParameters: params);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addHama(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/hama.php', data: data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateHamaResolved(String id, bool resolved) async {
    try {
      final response = await _dio.put('/hama.php', data: {'id': id, 'resolved': resolved});
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteHama(String id) async {
    try {
      final response = await _dio.delete('/hama.php', queryParameters: {'id': id});
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Panen API ---

  Future<Map<String, dynamic>> getPanen({String? sawahId}) async {
    try {
      final params = sawahId != null ? {'sawah_id': sawahId} : null;
      final response = await _dio.get('/panen.php', queryParameters: params);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addPanen(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/panen.php', data: data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updatePanen(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/panen.php', data: data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deletePanen(String id) async {
    try {
      final response = await _dio.delete('/panen.php', queryParameters: {'id': id});
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
