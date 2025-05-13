import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint("Rasm tanlashda xatolik: $e");
      rethrow;
    }
  }

  static Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint("Video tanlashda xatolik: $e");
      rethrow;
    }
  }

  static Future<void> clearTempFiles() async {
    try {
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final files = await tempDir.list().toList();
        for (final file in files) {
          try {
            if (file is File) await file.delete();
          } catch (e) {
            debugPrint("Faylni o'chirishda xatolik: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Temp fayllarni tozalashda xatolik: $e");
    }
  }
}