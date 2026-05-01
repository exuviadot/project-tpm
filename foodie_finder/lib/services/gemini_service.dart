import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // Mengambil API Key dari .env
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  static Future<String> getRecommendation(String prompt) async {
    // 1. Perbaikan logika pengecekan API Key
    if (_apiKey.isEmpty || _apiKey == 'YOUR_PLACEHOLDER_KEY') {
      return 'Sistem AI: API Key Gemini belum dikonfigurasi di file .env.';
    }

    try {
      // 2. Koreksi Nama Model: Gunakan 'gemini-1.5-flash' (versi stabil terbaru)
      // Saat ini belum ada versi 'gemini-2.5-flash-lite'.
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _apiKey,
      );

      // 3. Tambahkan System Instruction agar Bot lebih konsisten
      final content = [
        Content.text(
          'Kamu adalah Asisten Kuliner bernama FoodieBot. '
          'Jawablah secara singkat, ramah, dan berikan rekomendasi makanan '
          'atau tipe restoran berdasarkan input ini: $prompt'
        )
      ];

      final response = await model.generateContent(content);
      
      return response.text ?? 'Maaf, saya tidak bisa memproses permintaan saat ini.';
    } catch (e) {
      // Memberikan pesan error yang lebih mudah dipahami user
      return 'Terjadi kesalahan saat menghubungi FoodieBot: $e';
    }
  }
}