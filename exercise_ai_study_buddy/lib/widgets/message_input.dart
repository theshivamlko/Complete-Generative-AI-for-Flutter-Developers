import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final Function(String)? onImageSelected;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.isRecording = false,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
    this.onImageSelected,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
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
                onTap: () {
                  Navigator.pop(context);
                  _handleCameraCapture();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.deepPurple),
                title: const Text('Image Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handleGalleryPick();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCameraCapture() {
    // TODO: Implement camera capture with image_picker
  }

  void _handleGalleryPick() {
    // TODO: Implement gallery pick with image_picker
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRecording) {
      return _buildRecordingUI();
    }

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
        child: Row(
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
              icon: const Icon(Icons.mic, color: Colors.deepPurple),
              onPressed: widget.isLoading ? null : widget.onStartRecording,
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
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Animated recording indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                  size: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recording...',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Cancel button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: widget.onCancelRecording,
              tooltip: 'Cancel',
            ),
            // Stop/Send button
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: widget.onStopRecording,
                tooltip: 'Send Audio',
              ),
            ),
          ],
        ),
      ),
    );
  }
}




