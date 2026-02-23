import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'theme/app_theme.dart';
import 'models/chat_message.dart';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AiTutorApp());
}

class AiTutorApp extends StatelessWidget {
  const AiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Tutor',
      theme: AppTheme.dark,
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─── Chat Screen ──────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ── ValueNotifiers ──────────────────────────────────────────────────────────
  /// Full list of messages displayed in the chat.
  final ValueNotifier<List<ChatMessage>>
  _messagesNotifier = ValueNotifier<List<ChatMessage>>([
    ChatMessage(
      text:
          "Hi! I'm your AI Tutor ✨\nAsk me anything — I can explain concepts, analyse images, and more.",
      isUser: false,
    ),
  ]);

  /// Whether the AI is currently "typing" (shows the animated dots indicator).
  final ValueNotifier<bool> _isTypingNotifier = ValueNotifier<bool>(false);

  /// The image the user has attached but not yet sent.
  final ValueNotifier<XFile?> _selectedImageNotifier = ValueNotifier<XFile?>(
    null,
  );

  // ── Services ─────────────────────────────────────────────────────────────────
  final GeminiService _gemini = GeminiService(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _messagesNotifier.dispose();
    _isTypingNotifier.dispose();
    _selectedImageNotifier.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) _selectedImageNotifier.value = image;
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeSelectedImage() => _selectedImageNotifier.value = null;

  void _sendMessage() {
    final text = _textController.text.trim();
    final image = _selectedImageNotifier.value;
    if (text.isEmpty && image == null) return;

    final imagePath = image?.path;

    // 1. Add the user message
    _messagesNotifier.value = [
      ChatMessage(text: text, isUser: true, imagePath: imagePath),
      ..._messagesNotifier.value,
    ];
    _selectedImageNotifier.value = null;
    _textController.clear();
    _isTypingNotifier.value = true;

    _getAiReply(text, imagePath);
  }

  Future<void> _getAiReply(String userText, String? imagePath) async {
    // 2. Insert a blank AI bubble — we will stream tokens into it
    _messagesNotifier.value = [
      ChatMessage(text: '', isUser: false),
      ..._messagesNotifier.value,
    ];
    _isTypingNotifier.value = false;

    String accumulated = '';

    try {
      final stream = _gemini.sendMessageStream(userText, imagePath: imagePath);

      await for (final chunk in stream) {
        if (!mounted) return;
        accumulated += chunk;
        // 3. Replace the first (newest) AI bubble with the growing text
        final updated = List<ChatMessage>.from(_messagesNotifier.value);
        updated[0] = updated[0].copyWith(text: accumulated);
        _messagesNotifier.value = updated;
      }
    } catch (e) {
      if (!mounted) return;
      final updated = List<ChatMessage>.from(_messagesNotifier.value);
      updated[0] = updated[0].copyWith(
        text: '⚠️ Something went wrong: ${e.toString()}',
      );
      _messagesNotifier.value = updated;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScaffoldTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Message list — rebuilds only when messages list changes
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: _messagesNotifier,
              builder: (context, messages, _) {
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      ChatBubbleWidget(message: messages[index]),
                );
              },
            ),
          ),
          // ── Typing indicator — rebuilds only when _isTyping changes
          ValueListenableBuilder<bool>(
            valueListenable: _isTypingNotifier,
            builder: (context, isTyping, _) {
              if (!isTyping) return const SizedBox.shrink();
              return _buildTypingIndicator();
            },
          ),
          // ── Input area — rebuilds only when selected image changes
          ValueListenableBuilder<XFile?>(
            valueListenable: _selectedImageNotifier,
            builder: (context, selectedImage, _) {
              return _ChatInputArea(
                controller: _textController,
                selectedImage: selectedImage,
                onPickImage: _pickImage,
                onRemoveImage: _removeSelectedImage,
                onSend: _sendMessage,
              );
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppBarThemeConfig.background,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.appBarGlow),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.accent2, AppColors.accent1],
                center: Alignment.center,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent1.withAlpha(120),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('AI Tutor', style: AppBarThemeConfig.titleStyle),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7BF29A),
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 14, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF202032)],
          ),
          borderRadius: ChatBubbleTheme.aiRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 200),
            const SizedBox(width: 4),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    );
  }
}

// ─── Typing Dot ────────────────────────────────────────────────────────────

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.accent2, AppColors.accent1],
          ),
        ),
      ),
    );
  }
}

// ─── Chat Bubble ─────────────────────────────────────────────────────────────

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final gradient = isUser
        ? ChatBubbleTheme.userGradient
        : ChatBubbleTheme.aiGradient;
    final radius = isUser
        ? ChatBubbleTheme.userRadius
        : ChatBubbleTheme.aiRadius;
    final shadows = isUser
        ? ChatBubbleTheme.userShadow
        : ChatBubbleTheme.aiGlow;
    final textColor = isUser
        ? ChatBubbleTheme.userText
        : ChatBubbleTheme.aiText;

    return Padding(
      padding: ChatBubbleTheme.verticalMargin,
      child: Column(
        crossAxisAlignment: align,
        children: [
          // Small label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2, right: 2),
            child: Text(
              isUser ? 'You' : 'AI Tutor',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  ChatBubbleTheme.maxWidthFraction,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: radius,
              boxShadow: shadows,
            ),
            child: Padding(
              padding: ChatBubbleTheme.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attached image (top of bubble)
                  if (message.imagePath != null &&
                      message.imagePath!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: message.isNetworkImage
                            ? Image.network(
                                message.imagePath!,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, prog) {
                                  if (prog == null) return child;
                                  return Container(
                                    height: 140,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CircularProgressIndicator(
                                      color: AppColors.accent2,
                                      value: prog.expectedTotalBytes != null
                                          ? prog.cumulativeBytesLoaded /
                                                prog.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, e, st) => const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textSecondary,
                                  size: 40,
                                ),
                              )
                            : Image.file(
                                File(message.imagePath!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  // Text
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.4,
                        fontWeight: isUser ? FontWeight.w400 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Area ───────────────────────────────────────────────────────────────

class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSend;

  const _ChatInputArea({
    required this.controller,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: InputAreaTheme.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: InputAreaTheme.padding,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attached image preview
            if (selectedImage != null)
              _AttachedImagePreview(
                imagePath: selectedImage!.path,
                onRemove: onRemoveImage,
              ),
            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Image attach button
                _GradientIconButton(
                  icon: Icons.image_rounded,
                  gradient: AppGradients.accent,
                  onTap: onPickImage,
                  tooltip: 'Attach image',
                ),
                const SizedBox(width: 10),
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: InputAreaTheme.textFieldBg,
                      borderRadius: InputAreaTheme.textFieldRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      style: InputAreaTheme.textStyle,
                      cursorColor: AppColors.accent2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        hintStyle: const TextStyle(
                          color: InputAreaTheme.hintColor,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                _GradientSendButton(onTap: onSend),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachedImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;
  const _AttachedImagePreview({
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Stack(
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent1.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(180),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientIconButton extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final String tooltip;

  const _GradientIconButton({
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent1.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _GradientSendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientSendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: InputAreaTheme.sendButtonGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent1.withAlpha(120),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}
