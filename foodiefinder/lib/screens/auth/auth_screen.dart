import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500&q=80',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 32,
                  left: 24,
                  child: Text(
                    'FoodieFinder',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surface,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: 'Masuk'),
                        Tab(text: 'Daftar'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          LoginScreen(),
                          RegisterScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
