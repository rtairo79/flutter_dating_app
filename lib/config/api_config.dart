class ApiConfig {
  // Use your existing IP
  static const String baseUrl = 'http://192.168.8.14:8000/api/';

  static const Duration timeout = Duration(seconds: 30);

  // Endpoints
  static const String login = 'token/';
  static const String refreshToken = 'token/refresh/';
  static const String register = 'register/';
}