import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class GeminiService {
  static const _modelName = 'gemini-2.5-flash-lite';
  static const _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent';
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  final String _systemContext;

  GeminiService(List<Restaurant> restaurants)
    : _systemContext = _buildContext(restaurants);

  static String _buildContext(List<Restaurant> restaurants) {
    final names = restaurants.take(50).map((r) => '- ${r.name} (${r.cuisine})').join('\n');
    return '''
Kamu adalah Asisten Kuliner FoodieFinder, ahli kuliner Yogyakarta yang ramah dan informatif.
Tugas kamu: membantu pengguna menemukan dan memilih tempat makan di Yogyakarta.

Data restoran yang tersedia (sebagian):
$names

Panduan menjawab:
- Jawab dalam Bahasa Indonesia yang santai dan ramah
- Berikan rekomendasi spesifik berdasarkan preferensi user
- Jika user menyebut jenis makanan, sebutkan restoran yang relevan dari data
- Jangan sebut harga/fitur yang tidak ada di data
- Maksimal 3-4 kalimat per respons, tidak bertele-tele
''';
  }

  Future<String> chat(String userMessage, List<ChatMessage> history) async {
    if (_apiKey.isEmpty) {
      // Return a mock if no API key is provided
      await Future.delayed(const Duration(seconds: 1));
      return "Mohon maaf, API Key Gemini belum dikonfigurasi.";
    }

    final messages = [
      {'role': 'user', 'parts': [{'text': _systemContext}]},
      {'role': 'model', 'parts': [{'text': 'Siap! Saya Asisten Kuliner FoodieFinder. Ada yang bisa saya bantu?'}]},
      ...history.map((m) => {
        'role': m.isUser ? 'user' : 'model',
        'parts': [{'text': m.text}],
      }),
      {'role': 'user', 'parts': [{'text': userMessage}]},
    ];

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': messages}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Maaf, sedang ada gangguan pada server AI.";
      }
    } catch (e) {
      return "Gagal menghubungi server AI.";
    }
  }
}