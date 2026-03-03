# Image Picker Implementation Guide

## ✅ What Was Changed

The `MessageInput` widget has been updated to:
- ✅ Convert from `StatelessWidget` to `StatefulWidget`
- ✅ Add image source picker popup (Camera/Gallery)
- ✅ Show bottom sheet modal when image button is tapped
- ✅ Allow users to choose camera or image gallery
- ✅ Callback functions ready for implementation

---

## 🎯 How It Works

### Current Implementation
```
User Taps Image Button
    ↓
Bottom Sheet Popup Opens
    ↓
User Sees Two Options:
  1. Camera
  2. Image Gallery
    ↓
User Selects Option
    ↓
Corresponding handler called
```

### The Modal Popup
```
┌─────────────────────────────┐
│  Select Image Source        │
├─────────────────────────────┤
│ 📷 Camera                   │
│                             │
│ 🖼️  Image Gallery          │
└─────────────────────────────┘
```

---

## 📝 Code Structure

### Key Methods

#### `_showImageSourcePicker()`
- Opens a bottom sheet modal
- Displays two options: Camera and Gallery
- Each option has an icon and label
- Professional Material Design styling

#### `_handleCameraCapture()`
- Called when user selects Camera
- Currently has TODO placeholder
- Ready for `image_picker` package integration

#### `_handleGalleryPick()`
- Called when user selects Gallery
- Currently has TODO placeholder
- Ready for `image_picker` package integration

---

## 🔧 Next Steps: Full Implementation

### Step 1: Add image_picker Dependency

Edit `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_vertexai: ^0.2.2+1
  image_picker: ^1.0.0  # Add this line
```

Then run:
```bash
flutter pub get
```

### Step 2: Implement Camera Capture

Edit the `_handleCameraCapture()` method:
```dart
void _handleCameraCapture() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (image != null) {
      print('Image captured: ${image.path}');
      // TODO: Send image to AI or upload to Firebase
      // widget.onImageSelected?.call(image.path);
    }
  } catch (e) {
    print('Camera error: $e');
    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

### Step 3: Implement Gallery Pick

Edit the `_handleGalleryPick()` method:
```dart
void _handleGalleryPick() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (image != null) {
      print('Image selected: ${image.path}');
      // TODO: Send image to AI or upload to Firebase
      // widget.onImageSelected?.call(image.path);
    }
  } catch (e) {
    print('Gallery error: $e');
    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

### Step 4: Update ChatScreen Integration

In `lib/screens/chat_screen.dart`, update the MessageInput usage:
```dart
MessageInput(
  controller: _messageController,
  onSend: _handleSendMessage,
  isLoading: _isLoading,
  onImageSelected: (imagePath) {
    // Handle the selected image
    print('Image selected: $imagePath');
    // You can:
    // 1. Upload to Firebase Storage
    // 2. Send as message attachment
    // 3. Process with AI (vision)
  },
)
```

---

## 📸 Features Available

### Camera Features
- ✅ Take photo with device camera
- ✅ Quality control (85% quality)
- ✅ Error handling
- ✅ Permission handling (automatic)

### Gallery Features
- ✅ Browse device photos
- ✅ Select multiple images (can extend)
- ✅ Quality control
- ✅ Error handling
- ✅ Permission handling (automatic)

---

## 🔐 Permissions Required

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
</plist>
```

---

## 🎨 UI Customization

### Change Popup Style
Modify `_showImageSourcePicker()`:
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  // Add more properties as needed
)
```

### Add More Options
Add additional ListTiles in the popup:
```dart
ListTile(
  leading: const Icon(Icons.image_search, color: Colors.deepPurple),
  title: const Text('Search Images'),
  onTap: () {
    Navigator.pop(context);
    _handleImageSearch();
  },
),
```

---

## 📝 Full Implementation Example

Here's a complete implementation with all features:

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final Function(File)? onImageSelected;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.onImageSelected,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _handleCameraCapture();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.deepPurple),
                title: const Text('Image Gallery'),
                subtitle: const Text('Select from your photos'),
                onTap: () {
                  Navigator.pop(context);
                  _handleGalleryPick();
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCameraCapture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageSelected?.call(_selectedImage!);
      }
    } catch (e) {
      print('Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  void _handleGalleryPick() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageSelected?.call(_selectedImage!);
      }
    } catch (e) {
      print('Gallery error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show selected image preview if available
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    // TODO: Implement file attachment
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.grey),
                  onPressed: () {
                    _showImageSourcePicker(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.grey),
                  onPressed: () {
                    // TODO: Implement voice input
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: !widget.isLoading,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: widget.isLoading ? null : widget.onSend,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✨ Features of This Implementation

✅ **Bottom Sheet Popup** - Professional modal dialog
✅ **Camera Support** - Take photos with device camera
✅ **Gallery Support** - Select from device photos
✅ **Image Preview** - Show selected image before sending
✅ **Clear Button** - Remove selected image
✅ **Error Handling** - Catch and display errors
✅ **Quality Control** - Compress images to 85%
✅ **Permissions** - Automatically handled by package
✅ **Responsive** - Works on all devices

---

## 🧪 Testing

Test the image picker:
1. Tap the image button
2. Select Camera or Gallery
3. Take/select a photo
4. Image preview appears
5. Tap X to remove (optional)
6. Send message

---

## 📱 Platform Support

- ✅ Android - Full support
- ✅ iOS - Full support (need Info.plist)
- ✅ Web - Limited support (use file picker)
- ✅ macOS - Full support
- ✅ Windows - Limited support
- ✅ Linux - Limited support

---

## 🔗 Resources

- [image_picker package](https://pub.dev/packages/image_picker)
- [Flutter file picker](https://pub.dev/packages/file_picker)
- [Firebase Storage](https://firebase.google.com/docs/storage)

---

**The image picker popup is now ready!** 🎉

