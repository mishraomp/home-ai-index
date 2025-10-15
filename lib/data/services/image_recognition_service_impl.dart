import 'package:flutter/services.dart';
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/data/models/image_recognition_result.dart';
import 'package:home_ai_index/data/services/image_recognition_service.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Implementation of ImageRecognitionService using TensorFlow Lite
class ImageRecognitionServiceImpl implements ImageRecognitionService {

  ImageRecognitionServiceImpl(this._interpreter, this._labels);
  final Interpreter _interpreter;
  final List<String> _labels;

  // MobileNet v2 expects 224x224 RGB images
  static const int _inputSize = 224;

  // Category mapping for common household items
  static const Map<String, String> _labelToCategoryMap = {
    // Groceries
    'apple': 'groceries',
    'banana': 'groceries',
    'orange': 'groceries',
    'bread': 'groceries',
    'milk': 'groceries',
    'egg': 'groceries',
    'cheese': 'groceries',
    'meat': 'groceries',
    'vegetable': 'groceries',
    'fruit': 'groceries',

    // Electronics
    'laptop': 'electronics',
    'phone': 'electronics',
    'tablet': 'electronics',
    'computer': 'electronics',
    'camera': 'electronics',
    'television': 'electronics',
    'monitor': 'electronics',
    'keyboard': 'electronics',
    'mouse': 'electronics',

    // Tools
    'hammer': 'tools',
    'screwdriver': 'tools',
    'wrench': 'tools',
    'drill': 'tools',
    'saw': 'tools',
    'pliers': 'tools',

    // Kitchenware
    'plate': 'kitchenware',
    'bowl': 'kitchenware',
    'cup': 'kitchenware',
    'fork': 'kitchenware',
    'knife': 'kitchenware',
    'spoon': 'kitchenware',
    'pot': 'kitchenware',
    'pan': 'kitchenware',

    // Cleaning
    'vacuum': 'cleaning',
    'mop': 'cleaning',
    'broom': 'cleaning',
    'detergent': 'cleaning',

    // Toys
    'toy': 'toys',
    'doll': 'toys',
    'ball': 'toys',
    'puzzle': 'toys',

    // Clothing
    'shirt': 'clothing',
    'pants': 'clothing',
    'dress': 'clothing',
    'shoe': 'clothing',
    'jacket': 'clothing',

    // Furniture
    'chair': 'furniture',
    'table': 'furniture',
    'sofa': 'furniture',
    'bed': 'furniture',
    'desk': 'furniture',

    // Sports
    'basketball': 'sports',
    'football': 'sports',
    'tennis': 'sports',
    'bicycle': 'sports',

    // Books
    'book': 'books',
    'magazine': 'books',
    'notebook': 'books',
  };

  /// Factory constructor to initialize service from model file and labels
  static Future<ImageRecognitionServiceImpl> create(
    String modelPath, {
    String labelsPath = 'assets/ml_models/imagenet_labels.txt',
  }) async {
    try {
      // Load the model
      final interpreter = await Interpreter.fromAsset(modelPath);

      // Load the labels
      final labelsData = await rootBundle.loadString(labelsPath);
      final labels = labelsData.split('\n').map((e) => e.trim()).toList();

      return ImageRecognitionServiceImpl(interpreter, labels);
    } catch (e) {
      throw app_exceptions.ModelNotInitializedException(
        'Failed to load model from $modelPath: $e',
      );
    }
  }

  @override
  Future<ImageRecognitionResult> classifyImage(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const app_exceptions.ImageProcessingException(
          'Failed to decode image bytes',
        );
      }

      // Preprocess image
      final input = _preprocessImage(image);

      // Run inference - MobileNet v2 outputs 1001 classes (including background class at index 0)
      final output = List.filled(1, List.filled(1001, 0.0));
      _interpreter.run(input, output);

      // Find the label with highest confidence
      final predictions = output[0];
      double maxConfidence = 0.0;
      int maxIndex = 0;

      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      // Map index to label (simplified - in production, load from labels.txt)
      final label = _getLabelForIndex(maxIndex);
      final category = mapLabelToCategory(label);

      return ImageRecognitionResult(
        label: label,
        confidence: maxConfidence,
        suggestedCategory: category,
      );
    } on app_exceptions.ImageProcessingException {
      rethrow;
    } catch (e) {
      // Catch decoding errors and other processing errors
      if (e is RangeError || e is FormatException) {
        throw const app_exceptions.ImageProcessingException(
          'Invalid image format or corrupted data',
        );
      }
      throw app_exceptions.ModelNotInitializedException(
        'Model inference failed: $e',
      );
    }
  }

  /// Preprocesses image to model input format
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to 224x224
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Convert to normalized float array [1, 224, 224, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0, // Normalize to 0-1
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );

    return input;
  }

  /// Maps model output index to human-readable label
  String _getLabelForIndex(int index) {
    if (index >= 0 && index < _labels.length) {
      return _labels[index].replaceAll('_', ' ');
    }
    return 'unknown';
  }

  @override
  String mapLabelToCategory(String label) {
    final normalizedLabel = label.toLowerCase().trim();

    // Check direct mapping
    if (_labelToCategoryMap.containsKey(normalizedLabel)) {
      return _labelToCategoryMap[normalizedLabel]!;
    }

    // Check partial matches
    for (final entry in _labelToCategoryMap.entries) {
      if (normalizedLabel.contains(entry.key) ||
          entry.key.contains(normalizedLabel)) {
        return entry.value;
      }
    }

    // Default to 'other' if no match found
    return 'other';
  }

  @override
  void dispose() {
    _interpreter.close();
  }
}
