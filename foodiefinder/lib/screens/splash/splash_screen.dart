import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final prefsBox = await Hive.openBox('prefs');
    final isFirstTime = prefsBox.get('first_time', defaultValue: true);
    final token = await _secureStorage.read(key: 'jwt_token');

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (token != null) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text('FoodieFinder', style: AppTextStyles.heading1.copyWith(color: Colors.white)),
            Text('Temukan kuliner terbaik Jogja', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
