import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // TODO: Ganti dengan API Key Gemini yang valid
  static const String apiKey = 'AIzaSyDexBN5ndPxr3-Q0Qgf8XF2W5C5OFfXWY8';
  
  static Future<String> getRecommendation(String prompt) async {
    if (apiKey == 'AIzaSyDexBN5ndPxr3-Q0Qgf8XF2W5C5OFfXWY8') {
      return 'Sistem AI: API Key Gemini belum dikonfigurasi. Silakan tambahkan API key di lib/services/gemini_service.dart untuk mencoba fitur ini.';
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      final content = [Content.text('Kamu adalah Asisten Kuliner bernama FoodieBot. Jawablah secara singkat, ramah, dan berikan rekomendasi makanan atau tipe restoran berdasarkan input ini: $prompt')];
      final response = await model.generateContent(content);
      return response.text ?? 'Maaf, saya tidak bisa memproses permintaan saat ini.';
    } catch (e) {
      return 'Terjadi kesalahan saat menghubungi Asisten AI: $e';
    }
  }
}
