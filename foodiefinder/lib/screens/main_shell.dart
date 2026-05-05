import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../core/constants/app_colors.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late SensorService _sensorService;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sensorService = SensorService();
    _sensorService.startShakeDetection(() {
      Navigator.pushNamed(context, '/minigame');
    });
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),   label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded),     label: 'Peta'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded),  label: 'Profil'),
        ],
      ),
    );
  }
}
