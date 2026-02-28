import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();

  final List<Message> _messages = [
    Message.ai("Hello! I'm your AI Study Buddy. How can I help you today?"),
  ];

  bool _isLoading = false;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    // Add user message to the list
    setState(() {
      _messages.add(Message.user(userMessage));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Send message to Gemini and get response
      final aiResponse = await _aiService.sendMessage(userMessage);

      setState(() {
        _messages.add(Message.ai(aiResponse));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(Message.ai(
          "Sorry, I encountered an error: ${e.toString()}",
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const LoadingIndicator();
                }
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

