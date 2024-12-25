import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'successful_update_dialog.dart';

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _updatePassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Assuming user has logged in via password reset email link
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await user.updatePassword(_newPasswordController.text.trim());
          showDialog(
            context: context,
            builder: (context) => SuccessfulUpdateDialog(),
          );
        } else {
          _showErrorDialog(context, "User not authenticated. Please try again.");
        }
      } catch (e) {
        _showErrorDialog(context, "Failed to update password: $e");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Image.asset('assets/images/logo.png', width: 40, height: 40),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/new_password.png',
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create a New Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a new password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updatePassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
