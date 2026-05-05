import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../providers/chat_provider.dart';
import '../providers/restaurant_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'chat_bubble.dart';

class ChatbotPanel extends ConsumerStatefulWidget {
  const ChatbotPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends ConsumerState<ChatbotPanel> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  late GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    // Initialize gemini service with current restaurants
    Future.microtask(() async {
      final restaurants = await ref.read(allRestaurantsProvider.future);
      _geminiService = GeminiService(restaurants);
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final message = text.trim();
    _controller.clear();
    
    ref.read(chatHistoryNotifierProvider.notifier).addMessage(ChatMessage(text: message, isUser: true));
    
    setState(() {
      _isLoading = true;
    });

    final history = ref.read(chatHistoryNotifierProvider);
    final response = await _geminiService.chat(message, history);
    
    if (mounted) {
      ref.read(chatHistoryNotifierProvider.notifier).addMessage(ChatMessage(text: response, isUser: false));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatHistoryNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.smart_toy, color: AppColors.primary),
                const SizedBox(width: 8),
                Text("Asisten Kuliner AI", style: AppTextStyles.heading2),
                const Spacer(),
                const CloseButton(),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (_, i) => ChatBubble(message: messages[i]),
              ),
            ),
            if (_isLoading) const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            if (messages.isEmpty) _WelcomePrompts(onTap: _sendMessage),
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ketik pesan...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_controller.text),
            ),
          )
        ],
      ),
    );
  }
}

class _WelcomePrompts extends StatelessWidget {
  final Function(String) onTap;

  const _WelcomePrompts({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      "Rekomendasikan gudeg terenak di Jogja!",
      "Restoran apa yang cocok untuk makan siang hemat?",
      "Ada tempat makan yang hits di Jogja?",
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Tanya apa saja tentang kuliner Jogja 🍜", style: AppTextStyles.body),
        const SizedBox(height: 12),
        ...prompts.map((p) => InkWell(
          onTap: () => onTap(p),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(p, style: AppTextStyles.body),
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
