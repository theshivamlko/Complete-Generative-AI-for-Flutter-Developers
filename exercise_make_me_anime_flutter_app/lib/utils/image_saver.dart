import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class ImageUtils {
  static Future<void> saveImageToGallery({
    required BuildContext context,
    required File imageFile,
    String album = 'MakeMeAnime',
  }) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final request = await Gal.requestAccess(toAlbum: true);
        if (!request) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission to access gallery denied.'),
              ),
            );
          }
          return;
        }
      }

      await Gal.putImage(imageFile.path, album: album);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved successfully! at ${imageFile.path}'),
            backgroundColor: const Color(0xFF1ED760),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on GalException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: ${e.type.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }
}
