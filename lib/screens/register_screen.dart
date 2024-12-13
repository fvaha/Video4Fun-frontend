import 'package:flutter/material.dart';
import 'package:video_for_fun/api_service.dart';
import 'main_feed_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Function to handle registration
  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await registerUser(
        _usernameController.text.trim(),
        _emailController.text
            .trim(), // Using email instead of username for registration
        _passwordController.text,
      );

      // Assuming the response contains a success message or user info
      // ignore: unused_local_variable
      final successMessage = result['message'] ?? 'Registration successful!';

      // Navigate to the main feed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainFeed()),
      );
    } catch (e) {
      _showErrorDialog('Registration failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: "Email"), // Updated label
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
