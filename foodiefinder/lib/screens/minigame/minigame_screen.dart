import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/restaurant.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class MinigameScreen extends ConsumerStatefulWidget {
  const MinigameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MinigameScreen> createState() => _MinigameScreenState();
}

class _MinigameScreenState extends ConsumerState<MinigameScreen>
    with SingleTickerProviderStateMixin {
  List<Restaurant> _rouletteItems = [];
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  double _currentAngle = 0;
  Restaurant? _winner;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_rotationController.isAnimating || _rouletteItems.isEmpty) return;

    setState(() => _winner = null);

    final winnerIndex = Random().nextInt(_rouletteItems.length);
    final targetAngle = _getTargetAngleForWinner(winnerIndex);

    _rotationAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
        parent: _rotationController, curve: Curves.easeOutCubic));

    _rotationController
      ..duration = const Duration(seconds: 4)
      ..forward(from: 0).then((_) {
        setState(() {
          _currentAngle = _rotationAnimation.value;
          _winner = _rouletteItems[winnerIndex];
        });
      });
  }

  double _getTargetAngleForWinner(int winnerIndex) {
    final sweepAngle = 2 * pi / _rouletteItems.length;
    final winnerCenterAngle = sweepAngle * winnerIndex + sweepAngle / 2;
    final extraTurns = 5 + Random().nextInt(5);
    var targetAngle =
        ((_currentAngle / (2 * pi)).floor() + extraTurns) * 2 * pi -
            winnerCenterAngle;

    while (targetAngle <= _currentAngle) {
      targetAngle += 2 * pi;
    }

    return targetAngle;
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(allRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎰 Food Roulette', style: AppTextStyles.heading2),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: restaurantsAsync.when(
        data: (restaurants) {
          if (_rouletteItems.isEmpty && restaurants.isNotEmpty) {
            final shuffled = List<Restaurant>.from(restaurants)..shuffle();
            _rouletteItems = shuffled.take(8).toList();
          }

          if (_rouletteItems.isEmpty) {
            return const Center(child: Text("Tidak ada data restoran"));
          }

          return SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Goyangkan HP atau tekan Putar!",
                    style: AppTextStyles.heading2),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RoulettePainter(
                          segments: _rouletteItems,
                          rotation: _rotationController.isAnimating
                              ? _rotationAnimation.value
                              : _currentAngle),
                      size: const Size(300, 300),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  icon: const Icon(Icons.ads_click, color: Colors.white),
                  label: const Text('Putar!',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: _spin,
                ),
                const SizedBox(height: 32),
                if (_winner != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Column(
                      children: [
                        Text("Pemenang!",
                            style: AppTextStyles.heading2
                                .copyWith(color: AppColors.primary)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(_winner!.imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  height: 100, color: Colors.grey[300])),
                        ),
                        const SizedBox(height: 8),
                        Text(_winner!.name,
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/detail',
                              arguments: _winner),
                          child: const Text("Lihat Detail →"),
                        )
                      ],
                    ),
                  )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class RoulettePainter extends CustomPainter {
  final List<Restaurant> segments;
  final double rotation;

  RoulettePainter({required this.segments, required this.rotation});

  static const colors = [
    Color(0xFFFFB84D),
    Color(0xFFFF6B6B),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFF44336),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        rotation + sweepAngle * i,
        sweepAngle,
        true,
        paint,
      );
      _drawText(canvas, segments[i].name, center, radius,
          rotation + sweepAngle * i + sweepAngle / 2);
    }

    _drawPointer(canvas, center, radius);
  }

  void _drawText(
      Canvas canvas, String text, Offset center, double radius, double angle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.length > 10 ? '${text.substring(0, 10)}...' : text,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(radius / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawPointer(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = Colors.black87;
    final path = Path()
      ..moveTo(center.dx + radius - 22, center.dy)
      ..lineTo(center.dx + radius + 8, center.dy - 14)
      ..lineTo(center.dx + radius + 8, center.dy + 14)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
