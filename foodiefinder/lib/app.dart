import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/minigame/minigame_screen.dart';
import 'models/restaurant.dart';

class FoodieFinderApp extends StatelessWidget {
  const FoodieFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodieFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto', // Default fallback
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/auth':
            return MaterialPageRoute(builder: (_) => const AuthScreen());
          case '/main':
            return MaterialPageRoute(builder: (_) => const MainShell());
          case '/detail':
            final restaurant = settings.arguments as Restaurant;
            return MaterialPageRoute(builder: (_) => DetailScreen(restaurant: restaurant));
          case '/notifications':
            return MaterialPageRoute(builder: (_) => const NotificationScreen());
          case '/minigame':
            return MaterialPageRoute(builder: (_) => const MinigameScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
