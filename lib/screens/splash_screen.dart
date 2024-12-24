import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

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

    // Navigate to OnboardingScreen after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
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
        )),
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
            SizedBox(height: 20),
            // App title
            Stack(
              children: [
                Text(
                  'RecycLink',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2.0
                      ..color = Colors.white,
                  ),
                ),
                Stack(
                  children: [
                    // Text with a white border
                    Text(
                      'RecycLink',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth =
                              5.0 // Adjust for desired border thickness
                          ..color = Color(0xFFfffffb), // Border color
                      ),
                    ),
                    // Text with solid fill
                    Text(
                      'RecycLink',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005570), // Text fill color
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
