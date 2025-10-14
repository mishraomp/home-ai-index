import 'dart:typed_data';

import 'package:home_ai_index/data/models/image_recognition_result.dart';

/// Service for on-device image recognition using TensorFlow Lite
abstract class ImageRecognitionService {
  /// Classifies an image and returns recognition result
  Future<ImageRecognitionResult> classifyImage(Uint8List imageBytes);

  /// Maps a recognized label to a category
  String mapLabelToCategory(String label);

  /// Disposes of resources used by the service
  void dispose();
}
