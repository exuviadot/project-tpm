import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    Future.microtask(() => ref.read(authNotifierProvider.notifier).loadProfile());
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: AppTextStyles.heading2),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accent),
            onPressed: () => _logout(context, ref),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'User', style: AppTextStyles.heading1),
                  Text(user?.email ?? 'email@example.com', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('💬 ', style: TextStyle(fontSize: 18)),
                        Text('Kesan & Saran TPM', style: AppTextStyles.heading2),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Pesan kesan:\nTerima kasih atas ilmu yang sangat bermanfaat selama perkuliahan TPM. Proyek akhir ini merupakan penerapan dari berbagai materi mulai dari Layouting, State Management, API, Local Storage, Maps, hingga pemanfaatan sensor device dan AI.\n\nSaran:\nSemoga ke depannya materi perkuliahan bisa semakin update dengan teknologi terbaru.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengaturan', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                _SettingTile(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                _SettingTile(
                  icon: Icons.casino,
                  title: 'Minigame (Food Roulette)',
                  onTap: () => Navigator.pushNamed(context, '/minigame'),
                ),
                _SettingTile(
                  icon: Icons.info,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('FoodieFinder'),
                        content: Text('Versi 1.0.0\nAplikasi Rekomendasi Kuliner Yogyakarta.'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _logout(context, ref),
              child: const Text('Keluar', style: TextStyle(color: AppColors.accent, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
