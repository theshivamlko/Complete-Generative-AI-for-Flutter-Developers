# Code Architecture Documentation

## 📁 Project Structure

The codebase has been refactored following **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   └── message.dart            # Message data model
├── services/                    # Business logic & external APIs
│   └── ai_service.dart         # Firebase Vertex AI integration
├── screens/                     # Full-page screens
│   └── chat_screen.dart        # Main chat interface
└── widgets/                     # Reusable UI components
    ├── chat_app_bar.dart       # Custom app bar
    ├── chat_bubble.dart        # Message bubble widget
    ├── loading_indicator.dart  # AI thinking indicator
    └── message_input.dart      # Message input field
```

## 🏗️ Architecture Overview

### 1. **Models Layer** (`models/`)
Contains data structures and business entities.

#### `message.dart`
- **Purpose**: Represents a chat message
- **Properties**:
  - `text`: Message content
  - `isUser`: Whether it's from user or AI
  - `timestamp`: When the message was sent
- **Factory Methods**:
  - `Message.user(text)`: Create user message
  - `Message.ai(text)`: Create AI message
- **Methods**:
  - `copyWith()`: Immutable updates

```dart
// Usage example
final userMsg = Message.user("Hello!");
final aiMsg = Message.ai("Hi there!");
```

### 2. **Services Layer** (`services/`)
Handles business logic and external API integrations.

#### `ai_service.dart`
- **Purpose**: Manages Firebase Vertex AI (Gemini) integration
- **Responsibilities**:
  - Initialize Gemini model
  - Maintain chat session context
  - Send/receive messages
  - Handle API errors
  - Manage chat history

**Key Methods**:
```dart
AIService()                    // Constructor - auto-initializes AI
Future<String> sendMessage()   // Send message to Gemini
List<Content> getChatHistory() // Get conversation history
void resetChat()               // Start new conversation
```

**Configuration**:
- Model: `gemini-1.5-flash`
- System Instruction: Study Buddy persona
- Maintains context across conversation

### 3. **Widgets Layer** (`widgets/`)
Reusable, self-contained UI components.

#### `chat_app_bar.dart`
- **Purpose**: Custom app bar with online status
- **Props**:
  - `title`: App bar title
  - `isOnline`: Online status indicator
  - `onBackPressed`: Back button callback
  - `onMenuPressed`: Menu button callback

#### `chat_bubble.dart`
- **Purpose**: Display individual message bubble
- **Features**:
  - Different styles for user/AI messages
  - Avatar display
  - Timestamp formatting
  - Flexible width based on content
  - Shadow effects

#### `loading_indicator.dart`
- **Purpose**: Show AI is processing
- **Features**:
  - Animated progress indicator
  - "Thinking..." text
  - Consistent with message bubble style

#### `message_input.dart`
- **Purpose**: Message composition area
- **Features**:
  - Text input field
  - Attachment buttons (file, image, voice)
  - Send button
  - Disabled state during loading
  - Submit on Enter key

### 4. **Screens Layer** (`screens/`)
Complete page implementations combining widgets.

#### `chat_screen.dart`
- **Purpose**: Main chat interface
- **State Management**:
  - `_messages`: List of all messages
  - `_isLoading`: AI processing state
  - `_messageController`: Input field controller
  - `_scrollController`: Auto-scroll management
  - `_aiService`: AI service instance

**Key Methods**:
```dart
_sendMessage()      // Handle message sending
_scrollToBottom()   // Auto-scroll to latest
```

**UI Structure**:
```
Scaffold
├── ChatAppBar
└── Column
    ├── Expanded (Message List)
    │   └── ListView.builder
    │       ├── ChatBubble (foreach message)
    │       └── LoadingIndicator (if loading)
    └── MessageInput
```

## 🔄 Data Flow

### Message Sending Flow:

```
1. User types in MessageInput
   ↓
2. ChatScreen._sendMessage() called
   ↓
3. User message added to _messages list
   ↓
4. setState() triggers UI update (ChatBubble rendered)
   ↓
5. AIService.sendMessage() called
   ↓
6. LoadingIndicator shown
   ↓
7. Request sent to Firebase Vertex AI
   ↓
8. Gemini processes with conversation context
   ↓
9. Response received
   ↓
10. AI message added to _messages list
    ↓
11. setState() triggers UI update
    ↓
12. New ChatBubble rendered with response
```

## 🎯 Design Patterns Used

### 1. **Single Responsibility Principle**
- Each class has one clear purpose
- Models only hold data
- Services only handle business logic
- Widgets only render UI

### 2. **Dependency Injection**
- AIService injected into ChatScreen
- Props passed to widgets from parent

### 3. **Factory Pattern**
- `Message.user()` and `Message.ai()` factory constructors
- Simplifies message creation

### 4. **Repository Pattern**
- AIService acts as repository for AI communication
- Abstracts Firebase Vertex AI implementation

### 5. **Widget Composition**
- Small, reusable widgets
- ChatScreen composes multiple widgets
- Easy to test and modify

## 🔧 Extending the Application

### Adding New Features:

#### 1. **Add Image Upload**
```dart
// In services/
class ImageService {
  Future<String> uploadImage(File image) { ... }
}

// Use in ChatScreen
final _imageService = ImageService();
```

#### 2. **Add Message Persistence**
```dart
// In services/
class StorageService {
  Future<void> saveMessages(List<Message> messages) { ... }
  Future<List<Message>> loadMessages() { ... }
}
```

#### 3. **Add Multiple Chat Sessions**
```dart
// In models/
class ChatSession {
  final String id;
  final List<Message> messages;
  final DateTime created;
}

// In services/
class ChatSessionService {
  Future<List<ChatSession>> getAllSessions() { ... }
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
// Test models
test('Message.user creates user message', () {
  final msg = Message.user("Hello");
  expect(msg.isUser, true);
});

// Test services
test('AIService sends message', () async {
  final service = AIService();
  final response = await service.sendMessage("Test");
  expect(response, isNotEmpty);
});
```

### Widget Tests
```dart
testWidgets('ChatBubble displays message', (tester) async {
  final msg = Message.user("Test");
  await tester.pumpWidget(ChatBubble(message: msg));
  expect(find.text("Test"), findsOneWidget);
});
```

## 📊 Benefits of This Architecture

### ✅ **Maintainability**
- Easy to locate and fix issues
- Changes isolated to specific layers
- Clear code organization

### ✅ **Testability**
- Each component can be tested independently
- Mock services for UI tests
- Unit test models and services separately

### ✅ **Scalability**
- Easy to add new features
- Can swap AI providers by changing service
- Reusable widgets across screens

### ✅ **Readability**
- Self-documenting structure
- Clear naming conventions
- Logical file organization

### ✅ **Collaboration**
- Multiple developers can work simultaneously
- Clear boundaries between components
- Reduces merge conflicts

## 🚀 Quick Reference

### Import Paths
```dart
// Models
import 'package:exercise_ai_study_buddy/models/message.dart';

// Services
import 'package:exercise_ai_study_buddy/services/ai_service.dart';

// Widgets
import 'package:exercise_ai_study_buddy/widgets/chat_bubble.dart';

// Screens
import 'package:exercise_ai_study_buddy/screens/chat_screen.dart';
```

### Creating New Components

**New Model:**
```dart
// lib/models/new_model.dart
class NewModel {
  final String id;
  final String data;
  
  NewModel({required this.id, required this.data});
}
```

**New Service:**
```dart
// lib/services/new_service.dart
class NewService {
  Future<void> doSomething() async {
    // Implementation
  }
}
```

**New Widget:**
```dart
// lib/widgets/new_widget.dart
class NewWidget extends StatelessWidget {
  const NewWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**New Screen:**
```dart
// lib/screens/new_screen.dart
class NewScreen extends StatefulWidget {
  const NewScreen({super.key});
  
  @override
  State<NewScreen> createState() => _NewScreenState();
}
```

## 📝 File Size Summary

- **main.dart**: ~30 lines (minimal, just app setup)
- **message.dart**: ~42 lines (data model)
- **ai_service.dart**: ~50 lines (AI integration)
- **chat_app_bar.dart**: ~67 lines (app bar widget)
- **chat_bubble.dart**: ~103 lines (message bubble)
- **loading_indicator.dart**: ~68 lines (loading UI)
- **message_input.dart**: ~94 lines (input field)
- **chat_screen.dart**: ~118 lines (main screen)

**Total**: ~572 lines (previously 433 lines in single file)

## 🎓 Summary

This architecture follows industry best practices:
- ✅ Separation of Concerns
- ✅ Clean Architecture
- ✅ SOLID Principles
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability

Each component has a **single, well-defined responsibility** and can be modified, tested, and extended independently.

