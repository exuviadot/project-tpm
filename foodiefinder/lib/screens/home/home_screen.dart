import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/restaurant.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/special_recommendation_card.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/chatbot_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Restaurant? _selectedRestaurant;
  int _currentIndex = 0;
  
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 8; 

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _visibleCount += 8; // Tambah 8 rekomendasi lagi saat scroll mendekati bawah
      });
    }
  }

  void _pickRandomRestaurant(List<Restaurant> restaurants) {
    if (restaurants.isEmpty) return;
    int newIndex;
    do {
      newIndex = Random().nextInt(restaurants.length);
    } while (newIndex == _currentIndex && restaurants.length > 1);
    
    setState(() {
      _currentIndex = newIndex;
      _selectedRestaurant = restaurants[newIndex];
    });
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChatbotPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(allRestaurantsProvider);
    final user = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('FoodieFinder', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Minigame (Food Roulette)',
            onPressed: () => Navigator.pushNamed(context, '/minigame'),
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hai, ${user?.name ?? 'Foodie'}! 👋", style: AppTextStyles.heading1),
              const Text("Mau makan apa hari ini?", style: AppTextStyles.body),
              const SizedBox(height: 24),
              const Text("✨ Rekomendasi Spesial", style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              
              restaurantsAsync.when(
                data: (restaurants) {
                  if (restaurants.isEmpty) return const Text("Tidak ada data");
                  if (_selectedRestaurant == null) {
                    Future.microtask(() => _pickRandomRestaurant(restaurants));
                    return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                  }
                  
                  return Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: SpecialRecommendationCard(
                          key: ValueKey(_selectedRestaurant!.locationId),
                          restaurant: _selectedRestaurant!,
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: _selectedRestaurant),
                          onLocationTap: () {},
                          onMenuTap: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _pickRandomRestaurant(restaurants),
                          icon: const Icon(Icons.casino),
                          label: const Text('Acak Lagi 🎲'),
                        ),
                      )
                    ],
                  );
                },
                loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Text('Error: $err'),
              ),
              
              const SizedBox(height: 24),
              Text("Jelajahi Semua", style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              
              // Bagian Grid dengan limit tampilan
              restaurantsAsync.when(
                data: (restaurants) {
                  final currentItems = min(_visibleCount, restaurants.length);
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: currentItems, 
                    itemBuilder: (ctx, i) => RestaurantCard(
                      restaurant: restaurants[i],
                      onTap: () => Navigator.pushNamed(context, '/detail', arguments: restaurants[i]),
                    ),
                  );
                },
                loading: () => const ShimmerLoader(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChatbot,
        backgroundColor: AppColors.primary,
        tooltip: 'Asisten Kuliner AI',
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
    );
  }
}