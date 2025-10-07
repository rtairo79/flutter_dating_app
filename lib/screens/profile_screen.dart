// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/spotify_auth_service.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> _connectSpotify(BuildContext context) async {
    final token = await SpotifyAuthService.authenticateSpotify();
    if (token != null) {
      bool synced = await ApiService.syncSpotifyMusic(token);
      if (synced) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Spotify connected!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.music_note, color: Colors.green),
            title: Text('Connect Spotify'),
            subtitle: Text('Find matches based on music taste'),
            trailing: ElevatedButton(
              onPressed: () => _connectSpotify(context),
              child: Text('Connect'),
            ),
          ),
          // Other profile options...
        ],
      ),
    );
  }
}