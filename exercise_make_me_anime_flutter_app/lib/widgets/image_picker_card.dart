import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerCard extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final Color primaryColor;

  const ImagePickerCard({
    super.key,
    required this.selectedImage,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        clipBehavior: Clip.antiAlias,
        child: selectedImage != null
            ? Image.file(selectedImage!, fit: BoxFit.contain)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to Select Image',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
