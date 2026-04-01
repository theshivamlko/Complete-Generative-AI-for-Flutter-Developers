import 'dart:io';
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final bool hasResult;
  final File? generatedImageFile;
  final File? selectedImage;
  final String selectedFilter;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const ResultCard({
    super.key,
    required this.hasResult,
    required this.generatedImageFile,
    required this.selectedImage,
    required this.selectedFilter,
    required this.primaryColor,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasResult ? onTap : null,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasResult ? primaryColor : const Color(0xFF333333),
            width: hasResult ? 2 : 1,
          ),
          boxShadow: [
            if (hasResult)
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasResult
            ? Stack(
                alignment: Alignment.center,
                children: [
                  if (generatedImageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        generatedImageFile!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else if (selectedImage != null)
                    Opacity(
                      opacity: 0.4,
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  if (generatedImageFile == null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 50,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Style: $selectedFilter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap to view and save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  if (onEdit != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                          onPressed: onEdit,
                          tooltip: 'Edit with prompt',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                ],
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your generated image will appear here',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
