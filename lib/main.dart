import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:firebase_core/firebase_core.dart'; // Firebase Initialization
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on platform
  if (kIsWeb) {
    // Web Initialization
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyB6YJTbkxnhlAGRHkdrfhcxuDx40i1p8kc",
        authDomain: "waste-management-ebd7b.firebaseapp.com",
        projectId: "waste-management-ebd7b",
        storageBucket: "waste-management-ebd7b.appspot.com",
        messagingSenderId: "948890268716",
        appId: "1:948890268716:web:9f56aa00468ec008744d89",
        measurementId: "G-EN6Y4QV7JX",
      ),
    );
  } else {
    // Android Initialization
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecycLink',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
    );
  }
}
