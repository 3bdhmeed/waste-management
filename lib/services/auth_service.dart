import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<bool> signInUser(String email, String password, BuildContext context) async {
    UserCredential? credentials;

    try {
      credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      // Handle specific FirebaseAuth exceptions with user-friendly messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(ex.code))),
      );
      return false;
    } catch (e) {
      // Handle general errors
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred. Please try again.")),
      );
      return false;
    }

    User? user = credentials?.user ?? FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          // Access user data directly
          Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
          if (data != null) {
            String name = data['name'] ?? "No name";
            String email = data['email'] ?? "No email";
            print("User logged in: Name: $name, Email: $email");
          }
        } else {
          print("User document does not exist in Firestore");
        }
        return true;
      } catch (e) {
        print("Error fetching user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error retrieving user data. Please try again.")),
        );
        return false;
      }
    }

    print("No authenticated user found");
    return false;
  }

  // Helper method to map FirebaseAuth error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
