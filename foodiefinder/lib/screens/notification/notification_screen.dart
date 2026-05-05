import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: AppTextStyles.heading2),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationTile(
            title: "🍽️ Waktunya Makan Siang!",
            subtitle: "Jangan lupa istirahat dan makan ya 😊",
            time: "12:00 • Hari ini",
          ),
          _NotificationTile(
            title: "🎲 Belum tau mau makan apa?",
            subtitle: "Coba fitur Food Roulette kami!",
            time: "09:00 • Kemarin",
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _NotificationTile({required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: const Icon(Icons.notifications, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text(time, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
