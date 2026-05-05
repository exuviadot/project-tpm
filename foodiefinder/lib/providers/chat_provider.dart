import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/gemini_service.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatHistoryNotifier extends _$ChatHistoryNotifier {
  @override
  List<ChatMessage> build() {
    return [];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }
}
