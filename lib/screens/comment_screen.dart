import 'package:flutter/material.dart';
import 'package:video_for_fun/api_service.dart'; // Import api_services.dart

class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({super.key, required this.postId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<String> comments = [];
  TextEditingController commentController = TextEditingController();

  // Load comments for a specific post
  Future<void> loadComments() async {
    try {
      List<Map<String, dynamic>> loadedComments = await fetchComments(widget.postId);
      setState(() {
        comments = loadedComments.map<String>((comment) => comment['commentText'] as String).toList();
      });
    } catch (e) {
      print('Failed to load comments: $e');
    }
  }

  // Add a new comment
  Future<void> addComment() async {
    try {
      await addComment(widget.postId, '1', commentController.text); // Assuming userId = '1'
      setState(() {
        comments.add(commentController.text);
        commentController.clear();
      });
    } catch (e) {
      print('Failed to add comment: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(comments[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: "Add a comment..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
