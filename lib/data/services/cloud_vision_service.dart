
import 'package:home_ai_index/core/exceptions.dart' show NetworkException, AuthenticationException, QuotaExceededException, ApiException, TimeoutException;
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';

export 'cloud_vision_service_impl.dart';

/// Service interface for Google Cloud Vision API
abstract class CloudVisionService {
  /// Recognize objects in an image using Cloud Vision API
  ///
  /// Throws:
  /// - [ArgumentError] if request or credentials are invalid
  /// - [NetworkException] if network connection fails
  /// - [AuthenticationException] if API key is invalid (401, 403)
  /// - [QuotaExceededException] if API quota is exceeded (429)
  /// - [ApiException] for other API errors
  /// - [TimeoutException] if request times out
  Future<CloudVisionResponse> recognizeImage(
    CloudVisionRequest request,
    APICredentials credentials,
  );
}
