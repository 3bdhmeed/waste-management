import 'dart:ui';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'reset_password.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Call the signInUser method from AuthService
      bool success = await _authService.signInUser(
        _emailTextController.text.trim(),
        _passwordTextController.text.trim(),
        context,
      );

      if (success) {
        // Navigate to HomeScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // If login fails, show error message (handled inside AuthService)
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/Untitled-1.png', // Replace with the path to your image
            fit: BoxFit.cover, // To make the image cover the whole screen
          ),
        ),

        // Backdrop Filter for blur effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 2.0, sigmaY: 2.0), // Adjust the blur strength here
            // child: Container(
            //   color: const Color.fromARGB(255, 132, 255, 163).withOpacity(0.4), // Optional: adds a slight dark overlay
            // ),
          ),
        ),
        // Content on top of the blurred background
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.6,
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Login to Your Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextFormField("Email", _emailTextController, false),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                          "Password", _passwordTextController, true),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          elevation: 6,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.green,
                              )
                            : const Text("Login"),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  bool _isPasswordVisible =
      false; // State variable to toggle password visibility

  Widget _buildTextFormField(
      String labelText, TextEditingController controller, bool obscureText) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText && !_isPasswordVisible, // Toggle visibility
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText cannot be empty';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(
          labelText == "Email" ? Icons.email : Icons.lock,
          color: Colors.white.withOpacity(0.7),
        ),
        suffixIcon: labelText.contains("Password")
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  // Toggle the password visibility
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null, // Add suffix icon only for password fields
        filled: true,
        fillColor: Colors.green.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Colors.white, // Border color when focused
            width: 2.0,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      ),
    );
  }
}
