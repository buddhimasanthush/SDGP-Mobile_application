import 'package:flutter/material.dart';
import 'package:medifind_app/pages/main_navigation_page.dart';
import 'package:medifind_app/pages/splash_screen.dart';
import 'package:medifind_app/pages/terms_of_services_page.dart';
import 'package:medifind_app/pages/welcome_back_page.dart';
import 'package:medifind_app/pages/sign_in_page.dart';
import 'package:medifind_app/pages/sign_up_page.dart';
import 'package:medifind_app/pages/add_medicine_name_page.dart';
import 'package:medifind_app/services/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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
      // Starts at splash → terms → sign in/sign up → home
      // Users cannot reach home without completing auth flow
      home: const SplashScreen(),
      routes: {
        '/terms': (context) => const TermsOfServicesPage(),
        '/welcome': (context) => const WelcomeBackPage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const MainNavigationPage(),
        '/add_medicine_name': (context) => const AddMedicineNamePage(),
      },
    );
  }
}
