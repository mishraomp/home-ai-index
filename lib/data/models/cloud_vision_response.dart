import 'package:home_ai_index/core/exceptions.dart';

/// Represents the response from Google Cloud Vision API
class CloudVisionResponse {
  const CloudVisionResponse({required this.labelAnnotations, this.error});

  /// Parse from API JSON response
  factory CloudVisionResponse.fromJson(Map<String, dynamic> json) {
    final responses = json['responses'] as List?;
    if (responses == null || responses.isEmpty) {
      throw const ApiException('Empty response from API');
    }

    // Handle both Map<String, dynamic> and empty/invalid objects
    final firstResponse = responses[0];
    final Map<String, dynamic> responseMap =
        firstResponse is Map<String, dynamic> ? firstResponse : {};

    // Check for error in response
    if (responseMap.containsKey('error')) {
      return CloudVisionResponse(
        labelAnnotations: [],
        error: ErrorInfo.fromJson(responseMap['error']),
      );
    }

    // Parse label annotations
    final annotationsList = responseMap['labelAnnotations'] as List?;
    final annotations =
        annotationsList
            ?.map((json) {
              if (json is Map<String, dynamic>) {
                return LabelAnnotation.fromJson(json);
              }
              return null;
            })
            .whereType<LabelAnnotation>()
            .toList() ??
        [];

    return CloudVisionResponse(labelAnnotations: annotations);
  }

  /// Detected labels with confidence scores
  final List<LabelAnnotation> labelAnnotations;

  /// Error information if request failed
  final ErrorInfo? error;

  /// Get the top (highest confidence) label
  LabelAnnotation? get topLabel {
    if (labelAnnotations.isEmpty) return null;
    return labelAnnotations.first;
  }

  /// Check if response has valid labels
  bool get hasLabels => labelAnnotations.isNotEmpty;

  /// Check if response has an error
  bool get hasError => error != null;

  @override
  String toString() {
    if (hasError) {
      return 'CloudVisionResponse(error: $error)';
    }
    return 'CloudVisionResponse(labels: ${labelAnnotations.length})';
  }
}

/// Represents a label annotation from Cloud Vision API
class LabelAnnotation {
  const LabelAnnotation({
    required this.description,
    required this.score,
    this.topicality,
    this.mid,
  });

  /// Parse from JSON
  factory LabelAnnotation.fromJson(Map<String, dynamic> json) {
    return LabelAnnotation(
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
      topicality: (json['topicality'] as num?)?.toDouble(),
      mid: json['mid'] as String?,
    );
  }

  /// Human-readable label description (e.g., "Apple", "Fruit")
  final String description;

  /// Confidence score (0.0 to 1.0)
  final double score;

  /// Topicality score (optional, 0.0 to 1.0)
  final double? topicality;

  /// Knowledge Graph MID (optional)
  final String? mid;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'score': score,
      if (topicality != null) 'topicality': topicality,
      if (mid != null) 'mid': mid,
    };
  }

  /// Check if this is a high confidence label (>90%)
  bool get isHighConfidence => score > 0.9;

  /// Check if this is a medium confidence label (70-90%)
  bool get isMediumConfidence => score >= 0.7 && score <= 0.9;

  /// Check if this is a low confidence label (<70%)
  bool get isLowConfidence => score < 0.7;

  @override
  String toString() {
    return 'LabelAnnotation(description: $description, score: ${(score * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelAnnotation &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          score == other.score &&
          topicality == other.topicality &&
          mid == other.mid;

  @override
  int get hashCode =>
      description.hashCode ^
      score.hashCode ^
      topicality.hashCode ^
      mid.hashCode;
}

/// Represents error information from Cloud Vision API
class ErrorInfo {
  const ErrorInfo({
    required this.code,
    required this.message,
    required this.status,
  });

  /// Parse from JSON
  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
      code: json['code'] as int,
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }

  /// HTTP error code
  final int code;

  /// Human-readable error message
  final String message;

  /// Error status code (e.g., "INVALID_ARGUMENT")
  final String status;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'status': status};
  }

  @override
  String toString() {
    return 'ErrorInfo(code: $code, status: $status, message: $message)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorInfo &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          status == other.status;

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ status.hashCode;
}
