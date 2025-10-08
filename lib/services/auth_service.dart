import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Use the pre-configured Dio instance
  final Dio _dio = ApiService.dio; 

  Future<bool> login(String username, String password) async {
    try {
      // 1. Use the configured _dio instance
      final response = await _dio.post(
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
      
      // 2. Ensure userId is saved as a String for storage consistency
      final userId = decodedToken['user_id'].toString();
      await StorageService.saveUserId(userId);

      return true;
    } on DioException catch (e) {
      // 3. Improved error handling for API/Network issues
      print('Login Dio Error: ${e.response?.statusCode} - ${e.message}');
      // Consider re-throwing a custom error for the UI
      return false;
    } catch (e) {
      print('Unexpected Login Error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      // 1. Use the configured _dio instance
      await _dio.post( 
        '${ApiConfig.baseUrl}${ApiConfig.register}',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Auto login after registration
      return await login(username, password);
    } on DioException catch (e) {
      // 3. Improved error handling
      print('Register Dio Error: ${e.response?.statusCode} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected Register Error: $e');
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
      // This is purely an access token validity check.
      // Full implementation should involve refresh token logic in a Dio Interceptor.
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // Token is malformed or invalid
      print('JWT Decoding Error: $e');
      return false;
    }
  }
}