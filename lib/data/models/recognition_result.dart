import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:home_ai_index/core/utils/label_mapper.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';

/// Source of the recognition result
enum RecognitionSource {
  /// Google Cloud Vision API
  cloudVision,

  /// Offline TFLite model (deprecated)
  offline,

  /// User manual entry
  manual,
}

/// Represents the processed result of image recognition
///
/// This is the domain model that bridges between API responses
/// and the application's business logic.
class RecognitionResult extends Equatable {
  const RecognitionResult({
    required this.label,
    required this.category,
    required this.confidence,
    this.alternativeLabels = const [],
    required this.source,
  });

  /// Create from Cloud Vision API response
  factory RecognitionResult.fromCloudVision(
    CloudVisionResponse response,
    LabelMapper mapper,
  ) {
    final topLabel = response.topLabel;
    if (topLabel == null) {
      throw ArgumentError('No labels detected in Cloud Vision response');
    }

    final category = mapper.mapLabelToCategory(topLabel.description) ?? 'other';

    // Debug logging - show label to category mapping (only in debug mode)
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔄 LABEL TO CATEGORY MAPPING');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('Top Label: "${topLabel.description}"');
    debugPrint('Mapped Category: "$category"');
    debugPrint('Confidence: ${(topLabel.score * 100).toStringAsFixed(1)}%');
    debugPrint('═══════════════════════════════════════════════════════\n');

    // Get alternative labels (skip the first one, take next 3)
    final alternatives = response.labelAnnotations
        .skip(1)
        .take(3)
        .map((annotation) => annotation.description)
        .toList();

    return RecognitionResult(
      label: topLabel.description,
      category: category,
      confidence: topLabel.score,
      alternativeLabels: alternatives,
      source: RecognitionSource.cloudVision,
    );
  }

  /// Create for manual entry
  factory RecognitionResult.manual(String label, String category) {
    return RecognitionResult(
      label: label,
      category: category,
      confidence: 1.0,
      source: RecognitionSource.manual,
    );
  }

  /// Create for offline recognition (deprecated)
  factory RecognitionResult.offline({
    required String label,
    required String category,
    required double confidence,
  }) {
    return RecognitionResult(
      label: label,
      category: category,
      confidence: confidence,
      source: RecognitionSource.offline,
    );
  }

  /// Parse from JSON
  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      label: json['label'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      alternativeLabels:
          (json['alternativeLabels'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      source: RecognitionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => RecognitionSource.manual,
      ),
    );
  }

  /// Primary item name/label
  final String label;

  /// Mapped category (groceries, electronics, etc.)
  final String category;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Alternative suggested labels
  final List<String> alternativeLabels;

  /// Source of the recognition
  final RecognitionSource source;

  /// Check if confidence is high (>90%)
  bool get isHighConfidence => confidence > 0.9;

  /// Check if confidence is medium (70-90%)
  bool get isMediumConfidence => confidence >= 0.7 && confidence <= 0.9;

  /// Check if confidence is low (<70%)
  bool get isLowConfidence => confidence < 0.7;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'category': category,
      'confidence': confidence,
      'alternativeLabels': alternativeLabels,
      'source': source.name,
    };
  }

  /// Create a copy with some fields replaced
  RecognitionResult copyWith({
    String? label,
    String? category,
    double? confidence,
    List<String>? alternativeLabels,
    RecognitionSource? source,
  }) {
    return RecognitionResult(
      label: label ?? this.label,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      alternativeLabels: alternativeLabels ?? this.alternativeLabels,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
    label,
    category,
    confidence,
    alternativeLabels,
    source,
  ];

  @override
  String toString() {
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    return 'RecognitionResult(label: $label, category: $category, confidence: $confidencePercent%, source: $source)';
  }
}
