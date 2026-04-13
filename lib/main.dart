import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bari_project/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BariProjectApp());
}

class BariProjectApp extends StatelessWidget {
  const BariProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Home Sweet Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185FA5),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}