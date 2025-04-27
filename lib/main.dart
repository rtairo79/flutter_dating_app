import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/music_matches_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dating App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MapScreen(),
        '/music-matches': (context) => MusicMatchesScreen(userId: 1),  // пока статический userId, потом сделаешь динамическим
      },
    );
  }
}