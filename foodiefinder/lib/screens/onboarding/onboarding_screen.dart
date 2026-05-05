import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Temukan Kuliner Jogja',
      'desc': 'Jelajahi 200+ tempat makan terbaik di Yogyakarta',
      'icon': '🍜'
    },
    {
      'title': 'Lokasi Restoran Real-Time',
      'desc': 'Lihat peta semua restoran dan temukan yang terdekat dari kamu',
      'icon': '🗺️'
    },
    {
      'title': 'Asisten AI Kuliner',
      'desc': 'Tanya Asisten AI kami untuk rekomendasi personal',
      'icon': '🤖'
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefsBox = await Hive.openBox('prefs');
    await prefsBox.put('first_time', false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Lewati', style: TextStyle(color: AppColors.primary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_slides[i]['icon']!, style: const TextStyle(fontSize: 100)),
                    const SizedBox(height: 32),
                    Text(_slides[i]['title']!, style: AppTextStyles.heading1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _slides[i]['desc']!,
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == i ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == i ? AppColors.primary : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    if (_currentIndex == _slides.length - 1) {
                      _finishOnboarding();
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(
                    _currentIndex == _slides.length - 1 ? 'Mulai' : 'Lanjut',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
