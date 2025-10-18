import 'dart:io';
import 'dart:typed_data';

import 'package:home_ai_index/core/constants/app_constants.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/repositories/image_repository.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Implementation of ImageRepository for device file system
class ImageRepositoryImpl implements ImageRepository {
  @override
  Future<String> saveImage(Uint8List imageBytes, String itemId) async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${itemId}_$timestamp.jpg';
      final filePath = '${imagesDir.path}/$filename';

      // Write image to file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      throw FileSystemException('Failed to save image: $e');
    }
  }

  @override
  Future<Uint8List> generateThumbnail(Uint8List imageBytes) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      // Calculate thumbnail dimensions maintaining aspect ratio
      final thumbnail = img.copyResize(
        image,
        width: image.width > image.height ? thumbnailSize : null,
        height: image.height >= image.width ? thumbnailSize : null,
        interpolation: img.Interpolation.average,
      );

      // Encode as JPEG with quality setting
      final thumbnailBytes = img.encodeJpg(
        thumbnail,
        quality: imageCompressionQuality,
      );

      return Uint8List.fromList(thumbnailBytes);
    } catch (e) {
      throw ImageProcessingException('Failed to generate thumbnail: $e');
    }
  }

  @override
  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      // Start with configured quality
      int quality = imageCompressionQuality;
      Uint8List compressed = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      // Iteratively reduce quality if still over max size
      while (compressed.length > maxImageSizeBytes && quality > 50) {
        quality -= 10;
        compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      }

      // If still too large, resize the image
      if (compressed.length > maxImageSizeBytes) {
        const scale = 0.8;
        final resized = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.average,
        );

        compressed = Uint8List.fromList(
          img.encodeJpg(resized, quality: imageCompressionQuality),
        );
      }

      return compressed;
    } catch (e) {
      throw ImageProcessingException('Failed to compress image: $e');
    }
  }

  @override
  Future<String> getImagePath(String itemId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/images/${itemId}_*.jpg';
    } catch (e) {
      throw FileSystemException('Failed to get image path: $e');
    }
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail - file may already be deleted
      // This is acceptable for delete operations
    }
  }

  @override
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
