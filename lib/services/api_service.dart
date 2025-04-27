import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://127.0.0.1:8000/api/';

  static Future<List<dynamic>> getMusicMatches(int userId) async {
    final response = await http.get(Uri.parse('${baseUrl}users/$userId/music-matches/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка при получении данных (${response.statusCode})');
    }
  }

  static Future<bool> syncSpotifyMusic(String spotifyToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}spotify-sync/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'spotify_token': spotifyToken}),
    );
    return response.statusCode == 200;
  }
}