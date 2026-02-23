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

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    String? imagePath,
    bool? isNetworkImage,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      imagePath: imagePath ?? this.imagePath,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
    );
  }
}
