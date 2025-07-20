import 'package:dio/dio.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://example.com/api'));

  final Dio _dio;

  Future<String> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['message'] as String? ?? 'Success';
  }

  Future<String> signup(String email, String password) async {
    final response = await _dio.post('/signup', data: {
      'email': email,
      'password': password,
    });
    return response.data['message'] as String? ?? 'Success';
  }

  Future<String> resetPassword(String email) async {
    final response = await _dio.post('/forgot', data: {
      'email': email,
    });
    return response.data['message'] as String? ?? 'Success';
  }

  Future<String> logout() async {
    final response = await _dio.post('/logout');
    return response.data['message'] as String? ?? 'Success';
  }

  Future<String> deleteAccount() async {
    final response = await _dio.delete('/delete');
    return response.data['message'] as String? ?? 'Success';
  }
}
