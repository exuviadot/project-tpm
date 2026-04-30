import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  await NotificationService.init();
  runApp(const FoodieFinderApp());
}

class FoodieFinderApp extends StatelessWidget {
  const FoodieFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define Color Palette
    const Color primaryColor = Color(0xFF74512D);
    const Color secondaryColor = Color(0xFFAF8F6F);
    const Color surfaceColor = Color(0xFFF8F4E1);
    const Color onSurfaceColor = Color(0xFF543310);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Foodie Finder',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: surfaceColor,
          onSurface: onSurfaceColor,
        ),
        scaffoldBackgroundColor: surfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: secondaryColor,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: onSurfaceColor),
          bodyMedium: TextStyle(color: onSurfaceColor),
          titleLarge: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: onSurfaceColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Splash screen will just navigate to LoginScreen.
    // LoginScreen will handle biometric check if token exists.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'FoodieFinder',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
