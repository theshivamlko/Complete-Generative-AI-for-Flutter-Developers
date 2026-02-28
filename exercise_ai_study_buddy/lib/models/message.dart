class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Factory constructor for creating a user message
  factory Message.user(String text) {
    return Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  // Factory constructor for creating an AI message
  factory Message.ai(String text) {
    return Message(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // Copy with method for immutability
  Message copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

