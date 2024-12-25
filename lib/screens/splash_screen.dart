import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Repeat the animation

    // Check authentication state after 3 seconds
    Future.delayed(const Duration(seconds: 3), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is authenticated, navigate to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not authenticated, navigate to OnboardingScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/Untitled-1.png'),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating app logo
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 1.0).animate(_controller),
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            // App title
            const Text(
              'RecycLink',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
