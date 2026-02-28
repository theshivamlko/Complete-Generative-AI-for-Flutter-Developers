# Firebase Vertex AI Setup Guide

## 🎉 Chat App with Gemini AI Integration Complete!

Your Flutter app is now integrated with Firebase Vertex AI (Gemini) for real AI-powered conversations!

## What's Been Added

### 1. Dependencies
- Added `firebase_vertexai: ^0.2.2+1` to pubspec.yaml
- Installed the package successfully

### 2. Code Changes
- **Imported Firebase Vertex AI**: Added `firebase_vertexai` import
- **Initialized Gemini Model**: Using `gemini-1.5-flash` model
- **Chat Session**: Maintains conversation context across messages
- **System Instructions**: AI is configured as a helpful Study Buddy
- **Loading Indicator**: Shows "Thinking..." while AI generates responses
- **Error Handling**: Graceful error messages if AI fails

### 3. Features Implemented
✅ Real-time AI conversation using Gemini
✅ Maintains conversation history
✅ Loading state with animated indicator
✅ Error handling with user-friendly messages
✅ System instructions for Study Buddy persona

## 🚀 Required Setup Steps

### Step 1: Enable Vertex AI API in Firebase

You need to enable the Vertex AI API for your Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/project/demoproject-cbbe7)

2. Navigate to **Build** → **Vertex AI in Firebase** (or **Gemini API**)

3. Click **Get Started** or **Enable**

4. If prompted, enable billing for your project:
   - Firebase offers a free tier with generous limits
   - Gemini 1.5 Flash has a free tier: 15 requests per minute
   - See pricing: https://firebase.google.com/docs/vertex-ai/pricing

### Step 2: Verify Setup

After enabling Vertex AI:

1. Run the Flutter app:
   ```bash
   flutter run
   ```

2. Send a message to the AI Study Buddy

3. You should see:
   - "Thinking..." loading indicator
   - AI response from Gemini

### Step 3: Test the AI

Try these example prompts:
- "Explain quantum physics in simple terms"
- "Create a quiz about the solar system"
- "Help me understand photosynthesis"
- "What's the Pythagorean theorem?"

## 🔧 Troubleshooting

### Error: "API not enabled"
**Solution**: Enable Vertex AI API in Firebase Console (see Step 1 above)

### Error: "Quota exceeded"
**Solution**: 
- Check your Firebase Console quota limits
- Free tier: 15 requests/minute for Gemini 1.5 Flash
- Upgrade to paid plan if needed

### Error: "Permission denied"
**Solution**: 
- Ensure your Firebase project has billing enabled
- Check that the google-services.json is correctly configured

### No response from AI
**Solution**:
- Check your internet connection
- Verify Firebase is initialized correctly
- Check Firebase Console for API errors

## 📱 How It Works

1. **User sends message** → Text is captured from TextField
2. **Display user message** → Added to chat with timestamp
3. **Show loading** → "Thinking..." indicator appears
4. **Send to Gemini** → Message sent via ChatSession API
5. **Receive response** → AI generates contextual reply
6. **Display AI message** → Response shown in chat bubble
7. **Maintain context** → ChatSession remembers conversation history

## 🎨 Customization Options

### Change AI Model
```dart
_model = FirebaseVertexAI.instance.generativeModel(
  model: 'gemini-1.5-pro',  // More powerful model
);
```

### Modify System Instructions
Edit the `systemInstruction` in `_initializeAI()` to change AI behavior:
```dart
systemInstruction: Content.system(
  'You are a friendly tutor who specializes in mathematics...'
),
```

### Add Safety Settings
```dart
_model = FirebaseVertexAI.instance.generativeModel(
  model: 'gemini-1.5-flash',
  safetySettings: [
    SafetySetting(
      HarmCategory.hateSpeech,
      HarmBlockThreshold.high,
    ),
  ],
);
```

## 📚 Resources

- [Firebase Vertex AI Documentation](https://firebase.google.com/docs/vertex-ai)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter Firebase VertexAI Package](https://pub.dev/packages/firebase_vertexai)

## 🔐 Security Note

- The Gemini API is called from your Flutter app
- API key is embedded in the app (via Firebase config)
- Consider adding Firebase App Check for production apps
- Monitor usage in Firebase Console

---

**Setup completed**: February 28, 2026

**Next Step**: Enable Vertex AI API in your Firebase Console to start chatting!

