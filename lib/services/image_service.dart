import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
  
  Future<Uint8List?> getImageBytes(XFile imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      print('Error reading image bytes: $e');
      return null;
    }
  }
  
  bool isCameraAvailable() {
    // Camera is not available on web
    return !kIsWeb;
  }
} 