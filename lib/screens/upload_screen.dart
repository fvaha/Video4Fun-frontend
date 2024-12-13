import 'dart:io'; // For mobile file handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  String? _fileUrl; // For web preview
  String? _uploadedFileUrl;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [];
  bool _isUploading = false;

  // Backend URLs
  final String uploadUrl = 'http://10.0.2.2:8082/api/uploads';
  final String commentUrl = 'http://10.0.2.2:8082/api/comments/add';

  // File Picker
  Future<void> _pickFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = pickedFile;
        if (kIsWeb) {
          // Web-specific code to handle file preview
          _fileUrl = _generateFileUrl(pickedFile);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  // Web-specific file URL generation
  String _generateFileUrl(XFile pickedFile) {
    return pickedFile.path; // On Web, use the file path as the URL (temporary).
  }

  // File Upload
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      if (kIsWeb) {
        // Web-specific file upload using FormData
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        var fileBytes = await _selectedFile!.readAsBytes();
        var file = http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: _selectedFile!.name,
          contentType: MediaType.parse(lookupMimeType(_selectedFile!.path) ??
              'application/octet-stream'),
        );
        request.files.add(file);

        var response = await request.send();

        if (response.statusCode == 201) {
          final res = await http.Response.fromStream(response);
          setState(() {
            _uploadedFileUrl = res.body; // Assume backend returns URL
          });
        } else {
          throw Exception('File upload failed');
        }
      } else {
        // Mobile-specific file upload using MultipartRequest
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        var file = await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path,
          contentType: MediaType.parse(lookupMimeType(_selectedFile!.path) ??
              'application/octet-stream'),
        );
        request.files.add(file);

        var response = await request.send();

        if (response.statusCode == 201) {
          final res = await http.Response.fromStream(response);
          setState(() {
            _uploadedFileUrl = res.body; // Assume backend returns URL
          });
        } else {
          throw Exception('File upload failed');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Add Comment
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty || _uploadedFileUrl == null) return;

    try {
      final response = await http.post(
        Uri.parse(commentUrl),
        body: {
          'postId': '1234', // Replace with actual post ID
          'userId': 'user-id-here', // Replace with actual user ID
          'commentText': _commentController.text,
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          _comments.add({
            'username': 'User Name', // Replace with actual username
            'comment': _commentController.text,
          });
        });
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment added successfully")),
        );
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Media")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text("Pick an Image or Video"),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 16),
                Text("Selected file: ${_selectedFile!.name}"),
                const SizedBox(height: 10),
                kIsWeb
                    ? Image.network(_fileUrl!, height: 100, fit: BoxFit.cover)
                    : Image.file(File(_selectedFile!.path), height: 100),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadFile,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text("Upload File"),
                ),
              ],
              if (_uploadedFileUrl != null) ...[
                const SizedBox(height: 20),
                Text("Uploaded file URL: $_uploadedFileUrl"),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: "Add a comment"),
                ),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text("Add Comment"),
                ),
                const SizedBox(height: 20),
                const Text("Comments:"),
                ..._comments.map((comment) {
                  return ListTile(
                    title: Text(comment['username'] ?? 'Unknown'),
                    subtitle: Text(comment['comment'] ?? 'No comment'),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
