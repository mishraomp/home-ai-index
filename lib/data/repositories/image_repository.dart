import 'dart:typed_data';

/// Repository interface for image storage and processing operations
abstract class ImageRepository {
  /// Saves an image to device storage and returns the file path
  Future<String> saveImage(Uint8List imageBytes, String itemId);

  /// Generates a thumbnail from image bytes
  Future<Uint8List> generateThumbnail(Uint8List imageBytes);

  /// Compresses an image to reduce file size while maintaining quality
  Future<Uint8List> compressImage(Uint8List imageBytes);

  /// Gets the full path for an item's image
  Future<String> getImagePath(String itemId);

  /// Deletes an image file from storage
  Future<void> deleteImage(String imagePath);

  /// Checks if an image file exists
  Future<bool> imageExists(String imagePath);
}
