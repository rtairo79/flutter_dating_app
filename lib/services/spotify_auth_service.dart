import 'package:flutter_web_auth/flutter_web_auth.dart';

class SpotifyAuthService {
  static const clientId = 'ff7d278551ce4649a354055b04220b32';
  static const redirectUri = 'myapp://callback';

  static Future<String?> authenticateSpotify() async {
    final url =
        'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=token&redirect_uri=$redirectUri&scope=user-top-read';

    final result = await FlutterWebAuth.authenticate(
        url: url, callbackUrlScheme: "myapp");

    final token = Uri.parse(result)
        .fragment
        .split('&')
        .firstWhere((e) => e.startsWith('access_token'))
        .split('=')[1];

    return token;
  }
}