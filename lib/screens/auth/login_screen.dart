// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/spotify_auth_service.dart';
import '../../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoggedIn = false; // <- track login state so we can show Spotify button

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        // Persist local state if your AuthService doesn’t already do it
        setState(() => _isLoggedIn = true);

        // Option A: stay here and show a "Connect Spotify" button (recommended)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in. You can now connect Spotify.')),
        );

        // Option B (if you prefer): navigate to a post-login screen that also has the Spotify button
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
  }

  Future<void> _connectSpotifyAfterLogin() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      final token = await SpotifyAuthService.authenticateSpotify();
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spotify auth cancelled or failed')),
        );
        return;
      }

      // Debug: ensure we actually got a token
      // print('Spotify token: $token');

      final synced = await ApiService.syncSpotifyMusic(token);
      if (!mounted) return;

      if (synced) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spotify connected successfully!')),
        );

        // Now you can navigate to home/map/setup-profile after successful sync
        // Ensure this route exists, otherwise app will crash.
        Navigator.pushReplacementNamed(context, '/map');
        // or '/map' or '/setup-profile' – whichever is correct in your app.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync Spotify data')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spotify error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _loginWithCredentials,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Login'),
              ),

              // Register link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register"),
              ),

              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),

              // NOTE
              const Text(
                'Connect Spotify after login to find music matches',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // 🔥 SHOW THIS BUTTON ONLY AFTER CREDENTIAL LOGIN
              if (_isLoggedIn)
                ElevatedButton.icon(
                  onPressed: _connectSpotifyAfterLogin,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Connect Spotify'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
