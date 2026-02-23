import 'package:flutter/material.dart';
import 'pages/main_navigation_page.dart';

void main() {
  runApp(const MediFindApp());
}

class MediFindApp extends StatelessWidget {
  const MediFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediFind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0796DE),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}
