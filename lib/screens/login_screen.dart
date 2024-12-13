import 'package:flutter/material.dart';
import 'package:video_for_fun/api_service.dart'; // Import the api_services.dart
import 'package:video_for_fun/screens/register_screen.dart'; // Ensure register screen import

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Handle login logic
  Future<void> login() async {
    try {
      final result = await loginUser(
        emailController.text,
        passwordController.text,
      );

      // ignore: unnecessary_null_comparison
      if (result != null) {
        // Handle successful login, e.g., store user data, navigate to main feed
        Navigator.pushReplacementNamed(context, '/mainFeed');
      } else {
        _showErrorDialog('Invalid email or password.');
      }
    } catch (e) {
      // Handle login failure
      _showErrorDialog('Login failed: $e');
    }
  }

  // Helper function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Failed'),
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
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration screen if user is not registered
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
