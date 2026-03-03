import 'package:flutter/material.dart';
import '../models/message.dart';
import '../viewmodels/chat_view_model.dart';
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
  late final ChatViewModel _viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    // Listen to messages changes and scroll
    _viewModel.messagesNotifier.addListener(_scrollToBottom);
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

  void _handleSendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    await _viewModel.sendMessage(userMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _viewModel.messagesNotifier.removeListener(_scrollToBottom);
    _viewModel.dispose();
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
            child: ValueListenableBuilder<List<Message>>(
              valueListenable: _viewModel.messagesNotifier,
              builder: (context, messages, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoadingNotifier,
                  builder: (context, isLoading, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const LoadingIndicator();
                        }
                        final message = messages[index];
                        return ChatBubble(message: message);
                      },
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _viewModel.isLoadingNotifier,
            builder: (context, isLoading, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: _viewModel.isRecordingNotifier,
                builder: (context, isRecording, child) {
                  return MessageInput(
                    controller: _messageController,
                    onSend: _handleSendMessage,
                    isLoading: isLoading,
                    isRecording: isRecording,
                    onStartRecording: () async {
                      await _viewModel.startAudioRecording();
                    },
                    onStopRecording: () async {
                      await _viewModel.stopAndSendAudio();
                    },
                    onCancelRecording: () async {
                      await _viewModel.cancelAudioRecording();
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

