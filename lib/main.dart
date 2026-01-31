import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/api_auth_service.dart';
import 'utils/onboarding_utils.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (required for authentication)
  // TODO: Uncomment this line after Firebase setup is complete
  // Follow the guide: firebase_setup_guide.md
  // await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0d59f2),
          brightness: Brightness.light,
          primary: const Color(0xFF0d59f2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0d59f2),
          brightness: Brightness.dark,
          primary: const Color(0xFF0d59f2),
        ),
        scaffoldBackgroundColor: const Color(0xFF101622),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    // Check if onboarding is complete
    final isOnboardingComplete = await OnboardingUtils.isOnboardingComplete();
    
    if (!isOnboardingComplete) {
      // First time user - show onboarding
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
      return;
    }
    
    // Onboarding complete - check if user is logged in AND "Remember Me" is enabled
    final authService = ApiAuthService();
    final isLoggedIn = await authService.isLoggedIn();
    
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    // Only auto-login if token exists AND user checked "Remember Me"
    final shouldAutoLogin = isLoggedIn && rememberMe;
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => shouldAutoLogin
              ? const HomeScreen()
              : const OnboardingScreen(), // Show onboarding which has login button
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
