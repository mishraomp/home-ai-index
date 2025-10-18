import 'package:equatable/equatable.dart';

/// Represents the result of ML image recognition
///
/// Contains the detected label, confidence score, and suggested category
/// from the on-device TensorFlow Lite model.
class ImageRecognitionResult extends Equatable {

  const ImageRecognitionResult({
    required this.label,
    required this.confidence,
    required this.suggestedCategory,
  });

  /// Creates an ImageRecognitionResult from a JSON map
  factory ImageRecognitionResult.fromJson(Map<String, dynamic> json) {
    return ImageRecognitionResult(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
      suggestedCategory: json['suggestedCategory'] as String,
    );
  }
  /// Detected label from the ML model
  final String label;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Suggested category based on the label
  final String suggestedCategory;

  /// Converts this ImageRecognitionResult to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'suggestedCategory': suggestedCategory,
    };
  }

  /// Creates a copy of this ImageRecognitionResult with some fields replaced
  ImageRecognitionResult copyWith({
    String? label,
    double? confidence,
    String? suggestedCategory,
  }) {
    return ImageRecognitionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
    );
  }

  @override
  List<Object?> get props => [label, confidence, suggestedCategory];
}
