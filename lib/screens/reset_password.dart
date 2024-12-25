import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ResetPasswordScreen({super.key});

  Future<void> _sendResetPasswordEmail(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showDialog(context, "Error", "Email field cannot be empty.");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showDialog(context, "Error", "Please enter a valid email address.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showDialog(
        context,
        "Success",
        "A password reset link has been sent to $email. Please check your inbox.",
        onClose: () {
          Navigator.pop(context); // Navigate back to the previous screen (e.g., Login).
        },
      );
    } catch (e) {
      _showDialog(context, "Error", "Failed to send reset email. Please try again later.");
    }
  }

  void _showDialog(BuildContext context, String title, String message, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/reset_password.png',
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Reset your password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enter your email to receive a password reset link.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Send Reset Link"),
              onPressed: () => _sendResetPasswordEmail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
