class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;
  final bool isNetworkImage;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imagePath,
    this.isNetworkImage = false,
  });
}
