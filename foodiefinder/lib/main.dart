import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/notification_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dotenv
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Notifications
  await NotificationHelper.initialize();
  try {
    await NotificationHelper.scheduleMealReminders();
  } catch (e) {
    debugPrint("Notifikasi gagal dijadwalkan: $e");
  }

  runApp(
    const ProviderScope(
      child: FoodieFinderApp(),
    ),
  );
}
