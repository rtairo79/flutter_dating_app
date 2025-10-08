import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MusicMatchesScreen extends StatelessWidget {
  final int userId;

  const MusicMatchesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Music Matches")),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getMusicMatches(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(child: Text("Нет совпадений"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index]['username']),
                subtitle: Text("Общие музыкальные интересы найдены!"),
              );
            },
          );
        },
      ),
    );
  }
}