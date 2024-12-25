import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _rePasswordTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCitizen = false;
  bool isCompany = false;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (!isCitizen && !isCompany) {
        _showErrorDialog("Please select a user type");
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailTextController.text.trim(),
          password: _passwordTextController.text.trim(),
        );

        // Save user details to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': _userNameTextController.text.trim(),
          'email': _emailTextController.text.trim(),
          'userType': isCitizen ? 'Citizen' : 'Company',
        });

        // Navigate to HomeScreen after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = e.message ?? "An unknown error occurred";
        if (e.code == 'email-already-in-use') {
          message = "This email is already in use. Please log in instead.";
        }
        _showErrorDialog(message);
      } catch (e) {
        _showErrorDialog("An error occurred. Please try again.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Up Failed"),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0),
            child: Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField("Full Name", _userNameTextController, false),
                    const SizedBox(height: 15),
                    _buildTextFormField("Email", _emailTextController, false),
                    const SizedBox(height: 15),
                    _buildTextFormField("Password", _passwordTextController, true),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      "Re-Enter Password",
                      _rePasswordTextController,
                      true,
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "User Type",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isCitizen,
                          onChanged: (value) {
                            setState(() {
                              isCitizen = value!;
                              isCompany = false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.green,
                        ),
                        const Text(
                          "Citizen",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Checkbox(
                          value: isCompany,
                          onChanged: (value) {
                            setState(() {
                              isCompany = value!;
                              isCitizen = false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.green,
                        ),
                        const Text(
                          "Company",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.green)
                          : const Text("Sign Up"),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                            );
                          },
                          child: const Text(
                            " Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String labelText, TextEditingController controller, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$labelText cannot be empty";
        }
        if (labelText == "Email" &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email";
        }
        if (labelText == "Password" && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        if (labelText == "Re-Enter Password" &&
            value != _passwordTextController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}
