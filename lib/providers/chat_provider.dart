import 'package:flutter/foundation.dart';
import 'package:smart_campus/models/chat_message_model.dart';
import 'package:smart_campus/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: '0',
      text: '👋 Hey! I\'m your NTU Campus Assistant. Ask me about buildings, library, cafeteria, hostels, weather, sports, or anything campus-related!',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isTyping = true;
    notifyListeners();

    try {
      // Get bot response via service (simulated API call)
      final response = await _service.getResponse(text);

      _messages.add(ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isTyping = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessageModel(
      id: '0',
      text: '👋 Chat cleared. How can I help you?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
