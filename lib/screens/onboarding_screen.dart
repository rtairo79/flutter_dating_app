import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('Начать'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
    );
  }
}
