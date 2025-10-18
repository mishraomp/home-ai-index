import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/data/repositories/image_repository_impl.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageRepository', () {
    late ImageRepositoryImpl repository;

    setUp(() {
      repository = ImageRepositoryImpl();
    });

    group('generateThumbnail', () {
      test('should generate thumbnail from image bytes', () async {
        // Create a test image larger than thumbnail size
        final testImage = img.Image(width: 500, height: 500);
        img.fill(testImage, color: img.ColorRgb8(0, 255, 0));
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final result = await repository.generateThumbnail(imageBytes);

        expect(result, isNotNull);
        expect(result.length, lessThan(imageBytes.length));

        // Decode and verify thumbnail dimensions
        final thumbnail = img.decodeImage(result);
        expect(thumbnail, isNotNull);
        expect(thumbnail!.width, lessThanOrEqualTo(200));
        expect(thumbnail.height, lessThanOrEqualTo(200));
      });

      test('should maintain aspect ratio when generating thumbnail', () async {
        // Create a wide image
        final testImage = img.Image(width: 800, height: 400);
        img.fill(testImage, color: img.ColorRgb8(0, 0, 255));
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final result = await repository.generateThumbnail(imageBytes);
        final thumbnail = img.decodeImage(result);

        expect(thumbnail, isNotNull);
        expect(thumbnail!.width / thumbnail.height, closeTo(2.0, 0.1));
      });

      test('should throw ImageProcessingException on invalid image data',
          () async {
        final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        expect(
          () => repository.generateThumbnail(invalidBytes),
          throwsA(isA<app_exceptions.ImageProcessingException>()),
        );
      });
    });

    group('compressImage', () {
      test('should compress image to reduce file size', () async {
        // Create a large test image with more complexity for better compression
        final testImage = img.Image(width: 1000, height: 1000);
        // Create a pattern to make it more compressible
        for (var y = 0; y < testImage.height; y++) {
          for (var x = 0; x < testImage.width; x++) {
            final color = (x + y) % 2 == 0
                ? img.ColorRgb8(255, 255, 255)
                : img.ColorRgb8(0, 0, 0);
            testImage.setPixel(x, y, color);
          }
        }
        final originalBytes =
            Uint8List.fromList(img.encodeJpg(testImage));

        final result = await repository.compressImage(originalBytes);

        expect(result, isNotNull);
        expect(result.length, lessThanOrEqualTo(originalBytes.length));

        // Verify it's still a valid image
        final compressed = img.decodeImage(result);
        expect(compressed, isNotNull);
      });

      test('should respect max file size', () async {
        final testImage = img.Image(width: 2000, height: 2000);
        img.fill(testImage, color: img.ColorRgb8(255, 255, 255));
        final originalBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final result = await repository.compressImage(originalBytes);

        // Should be under 2MB (maxImageSizeBytes)
        expect(result.length, lessThanOrEqualTo(2 * 1024 * 1024));
      });

      test('should throw ImageProcessingException on invalid image', () async {
        final invalidBytes = Uint8List.fromList([0, 0, 0]);

        expect(
          () => repository.compressImage(invalidBytes),
          throwsA(isA<app_exceptions.ImageProcessingException>()),
        );
      });
    });
  });
}
