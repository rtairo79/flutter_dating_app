import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService.dio;

  Future<bool> login(String username, String password) async {
    try {
      final response = await Dio().post(
        '${ApiConfig.baseUrl}${ApiConfig.login}',
        data: {
          'username': username,
          'password': password,
        },
      );

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      await StorageService.saveToken(accessToken);
      await StorageService.saveRefreshToken(refreshToken);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      await StorageService.saveUserId(decodedToken['user_id']);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await Dio().post(
        '${ApiConfig.baseUrl}${ApiConfig.register}',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Auto login after registration
      return await login(username, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
}