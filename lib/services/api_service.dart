// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.timeout,
    receiveTimeout: ApiConfig.timeout,
    headers: {'Content-Type': 'application/json'},
  ))..interceptors.add(AuthInterceptor());

  static Dio get dio => _dio;

  // Keep your existing methods but use Dio
  static Future<List<dynamic>> getMusicMatches(int userId) async {
    try {
      final response = await _dio.get('users/$userId/music-matches/');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error fetching music matches: ${e.message}');
    }
  }

  static Future<bool> syncSpotifyMusic(String spotifyToken) async {
    try {
      final response = await _dio.post(
        'spotify-sync/',
        data: {'spotify_token': spotifyToken},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Error syncing Spotify: ${e.message}');
    }
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getToken();
    if (token != null && !options.path.contains('token/') && !options.path.contains('register/')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${ApiConfig.baseUrl}token/refresh/',
            data: {'refresh': refreshToken},
          );

          final newToken = response.data['access'];
          await StorageService.saveToken(newToken);

          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final cloneReq = await Dio().fetch(err.requestOptions);
          return handler.resolve(cloneReq);
        } catch (e) {
          await StorageService.clearAll();
          // TODO: Navigate to login screen
        }
      }
    }
    handler.next(err);
  }
}