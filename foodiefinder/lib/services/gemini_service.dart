import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Restaurant> recommendedRestaurants;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.recommendedRestaurants = const [],
  });
}

class AiRecommendationResult {
  final String message;
  final List<Restaurant> recommendedRestaurants;

  AiRecommendationResult({
    required this.message,
    required this.recommendedRestaurants,
  });
}

class GeminiService {
  static const _modelName = 'gemini-2.5-flash-lite';
  static const _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent';

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  final List<Restaurant> restaurants;
  final String _systemContext;

  GeminiService(this.restaurants) : _systemContext = _buildContext(restaurants);

  static String _buildContext(List<Restaurant> restaurants) {
    final names = restaurants.take(50).map((r) {
      return '- location_id: ${r.locationId}, name: ${r.name}, cuisine: ${r.cuisine}';
    }).join('\n');

    return '''
Kamu adalah Asisten Kuliner FoodieFinder, ahli kuliner Yogyakarta yang ramah dan informatif.

Tugas kamu:
- Membantu user memilih restoran dari data yang tersedia.
- Jangan mengarang restoran yang tidak ada di data.
- Pilih maksimal 3 restoran yang paling relevan.

Data restoran:
$names

Format jawaban WAJIB JSON valid saja, tanpa markdown, tanpa ```json.

Contoh format:
{
  "message": "Aku rekomendasikan beberapa tempat yang cocok buat kamu.",
  "location_ids": ["way/122889730", "way/20000001", "way/20000002"]
}

Aturan:
- "message" harus Bahasa Indonesia santai dan ramah.
- "location_ids" hanya boleh berisi nilai location_id persis dari data, misalnya "way/122889730".
- Jika tidak ada yang cocok, isi "location_ids": [].
- Jangan sebut harga/rating/fasilitas kalau tidak ada di data.
''';
  }

  List<Restaurant> _findRecommendedRestaurants(
    Map<String, dynamic> jsonResult,
    String userMessage,
  ) {
    final rawIds = (jsonResult['location_ids'] as List? ?? const [])
        .map((id) => id.toString().trim())
        .where((id) => id.isNotEmpty)
        .toList();
    final recommended = <Restaurant>[];

    void addUnique(Restaurant restaurant) {
      if (!recommended
          .any((item) => item.locationId == restaurant.locationId)) {
        recommended.add(restaurant);
      }
    }

    for (final id in rawIds) {
      final normalizedId = id.toLowerCase();

      for (final restaurant in restaurants) {
        final candidates = [
          restaurant.locationId,
          restaurant.locationId.split('/').last,
          restaurant.ranking.toString(),
          restaurant.name,
        ].map((value) => value.toLowerCase());

        if (candidates.contains(normalizedId)) {
          addUnique(restaurant);
          break;
        }
      }
    }

    if (recommended.isNotEmpty) return recommended.take(3).toList();

    final query = userMessage.toLowerCase();
    final fallback = restaurants
        .where((restaurant) {
          final cuisine = restaurant.cuisine.toLowerCase();
          final name = restaurant.name.toLowerCase();

          return (cuisine.isNotEmpty && query.contains(cuisine)) ||
              (name.isNotEmpty && query.contains(name));
        })
        .take(3)
        .toList();

    return fallback;
  }

  Future<AiRecommendationResult> chat(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      return AiRecommendationResult(
        message: "Mohon maaf, API Key Gemini belum dikonfigurasi.",
        recommendedRestaurants: [],
      );
    }

    final messages = [
      {
        'role': 'user',
        'parts': [
          {'text': _systemContext}
        ],
      },
      {
        'role': 'model',
        'parts': [
          {
            'text':
                '{"message":"Siap! Saya Asisten Kuliner FoodieFinder. Ada yang bisa saya bantu?","location_ids":[]}'
          }
        ],
      },
      ...history.map((m) => {
            'role': m.isUser ? 'user' : 'model',
            'parts': [
              {'text': m.text}
            ],
          }),
      {
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ],
      },
    ];

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': messages,
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 300,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        final cleanedText =
            rawText.replaceAll('```json', '').replaceAll('```', '').trim();

        final jsonResult = jsonDecode(cleanedText);

        final message = jsonResult['message'] ?? 'Ini rekomendasi buat kamu.';
        final recommended =
            _findRecommendedRestaurants(jsonResult, userMessage);
        print('LOCATION IDS: ${jsonResult['location_ids']}');
        print('RECOMMENDED COUNT: ${recommended.length}');

        return AiRecommendationResult(
          message: message,
          recommendedRestaurants: recommended,
        );
      } else {
        print('GEMINI STATUS: ${response.statusCode}');
        print('GEMINI BODY: ${response.body}');

        return AiRecommendationResult(
          message: "Maaf, sedang ada gangguan pada server AI.",
          recommendedRestaurants: [],
        );
      }
    } catch (e) {
      print('GEMINI ERROR: $e');

      return AiRecommendationResult(
        message: "Gagal menghubungi server AI.",
        recommendedRestaurants: [],
      );
    }
  }
}
