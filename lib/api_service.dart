import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:http/http.dart'; // Import for multipart file uploads

// Base URL for your API
const String apiUrl = 'http://10.0.2.2:8082/api';

// Register user
Future<Map<String, dynamic>> registerUser(
    String username, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Registration failed with status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to register user: $e');
  }
}

// Login user
Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Return the parsed response
    } else {
      throw Exception('Login failed with status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to login user: $e');
  }
}

// Fetch posts
Future<List<Map<String, dynamic>>> fetchPosts(int page) async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/posts?page=$page'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load posts with status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch posts: $e');
  }
}

// Upvote a post
Future<void> upvotePost(int postId) async {
  try {
    final response = await http.post(Uri.parse('$apiUrl/posts/$postId/upvote'));

    if (response.statusCode != 200) {
      throw Exception('Failed to upvote post, status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to upvote post: $e');
  }
}

// Downvote a post
Future<void> downvotePost(int postId) async {
  try {
    final response =
        await http.post(Uri.parse('$apiUrl/posts/$postId/downvote'));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to downvote post, status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to downvote post: $e');
  }
}

// Upload a file
Future<String> uploadFile(String filePath) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/uploads'));
    var file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

    var response = await request.send();

    if (response.statusCode == 201) {
      final res = await http.Response.fromStream(response);
      return res
          .body; // Assuming the backend returns the URL of the uploaded file
    } else {
      throw Exception('File upload failed, status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to upload file: $e');
  }
}

// Fetch comments for a specific post
Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/comments/$postId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['comments'];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load comments');
    }
  } catch (e) {
    throw Exception('Failed to load comments: $e');
  }
}

// Add a new comment to a post
Future<void> addComment(int postId, String userId, String commentText) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/comments/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'postId': postId,
        'userId': userId,
        'commentText': commentText,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  } catch (e) {
    throw Exception('Failed to add comment: $e');
  }
}
