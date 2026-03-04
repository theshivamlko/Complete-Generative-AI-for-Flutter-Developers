enum MessageType {
  text,
  audio,
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  // Factory constructor for creating a user message
  factory Message.user(String text) {
    return Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  // Factory constructor for creating an AI message
  factory Message.ai(String text) {
    return Message(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  // Factory constructor for creating a user audio message
  factory Message.userAudio() {
    return Message(
      text: '🎤 Voice message',
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.audio,
    );
  }

  // Copy with method for immutability
  Message copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

