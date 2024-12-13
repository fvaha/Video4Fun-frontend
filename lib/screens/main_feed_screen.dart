import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'comment_screen.dart';

class MainFeed extends StatefulWidget {
  @override
  _MainFeedState createState() => _MainFeedState();
}

class _MainFeedState extends State<MainFeed> {
  List<Map<String, dynamic>> posts = [];
  final String apiUrl = 'http://localhost:8082/api/posts';

  // Load posts for the feed
  Future<void> loadPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        posts = data.map((post) => post as Map<String, dynamic>).toList();
      });
    } else {
      // Handle error
      print('Failed to load posts');
    }
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Main Feed")),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['content']),
            onTap: () {
              // Navigate to comment screen on tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentScreen(postId: post['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
