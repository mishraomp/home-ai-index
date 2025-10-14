import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/data/models/image_recognition_result.dart';
import 'package:home_ai_index/data/services/image_recognition_service_impl.dart';

@GenerateMocks([Interpreter])
import 'image_recognition_service_test.mocks.dart';

void main() {
  group('ImageRecognitionService', () {
    late ImageRecognitionServiceImpl service;
    late MockInterpreter mockInterpreter;
    late List<String> mockLabels;

    setUp(() {
      mockInterpreter = MockInterpreter();
      // Create mock labels list with 1001 entries (0-1000)
      mockLabels = List.generate(1001, (i) => 'label_$i');
      mockLabels[0] = 'background';
      mockLabels[123] = 'test_object';
      service = ImageRecognitionServiceImpl(mockInterpreter, mockLabels);
    });

    group('classifyImage', () {
      test('should return recognition result with label and confidence',
          () async {
        // Create a test image
        final testImage = img.Image(width: 224, height: 224);
        img.fill(testImage, color: img.ColorRgb8(128, 128, 128));
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        // Mock interpreter output - simulating model prediction
        when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
          final output = invocation.positionalArguments[1] as List;
          // Simulate a prediction: index 123 has confidence 0.85
          output[0][123] = 0.85;
        });

        final result = await service.classifyImage(imageBytes);

        expect(result, isNotNull);
        expect(result.label, isNotEmpty);
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
        verify(mockInterpreter.run(any, any)).called(1);
      });

      test('should preprocess image to 224x224', () async {
        // Create a different sized image
        final testImage = img.Image(width: 500, height: 300);
        img.fill(testImage, color: img.ColorRgb8(255, 0, 0));
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
          final input = invocation.positionalArguments[0];
          // Verify input shape is [1, 224, 224, 3]
          expect(input, hasLength(1));
          expect(input[0], hasLength(224));
          expect(input[0][0], hasLength(224));
          expect(input[0][0][0], hasLength(3));

          final output = invocation.positionalArguments[1] as List;
          output[0][0] = 0.9;
        });

        await service.classifyImage(imageBytes);

        verify(mockInterpreter.run(any, any)).called(1);
      });

      test('should normalize pixel values to 0-1 range', () async {
        final testImage = img.Image(width: 224, height: 224);
        img.fill(testImage, color: img.ColorRgb8(255, 128, 0));
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
          final input = invocation.positionalArguments[0];
          // Check that pixel values are normalized (0-1 range)
          final pixelValue = input[0][0][0][0];
          expect(pixelValue, greaterThanOrEqualTo(0.0));
          expect(pixelValue, lessThanOrEqualTo(1.0));

          final output = invocation.positionalArguments[1] as List;
          output[0][50] = 0.75;
        });

        await service.classifyImage(imageBytes);

        verify(mockInterpreter.run(any, any)).called(1);
      });

      test('should return highest confidence prediction', () async {
        final testImage = img.Image(width: 224, height: 224);
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
          final output = invocation.positionalArguments[1] as List;
          output[0][10] = 0.3; // Lower confidence
          output[0][20] = 0.95; // Highest confidence
          output[0][30] = 0.6; // Medium confidence
        });

        final result = await service.classifyImage(imageBytes);

        expect(result.confidence, 0.95);
      });

      test('should throw ImageProcessingException on invalid image', () async {
        final invalidBytes = Uint8List.fromList([1, 2, 3]);

        expect(
          () => service.classifyImage(invalidBytes),
          throwsA(isA<app_exceptions.ImageProcessingException>()),
        );
      });

      test('should throw ModelNotInitializedException if model fails',
          () async {
        final testImage = img.Image(width: 224, height: 224);
        final imageBytes = Uint8List.fromList(img.encodeJpg(testImage));

        when(mockInterpreter.run(any, any)).thenThrow(Exception('Model error'));

        expect(
          () => service.classifyImage(imageBytes),
          throwsA(isA<app_exceptions.ModelNotInitializedException>()),
        );
      });
    });

    group('mapLabelToCategory', () {
      test('should map food items to groceries category', () {
        final result = service.mapLabelToCategory('apple');
        expect(result, 'groceries');

        final result2 = service.mapLabelToCategory('banana');
        expect(result2, 'groceries');
      });

      test('should map tools to tools category', () {
        final result = service.mapLabelToCategory('hammer');
        expect(result, 'tools');

        final result2 = service.mapLabelToCategory('screwdriver');
        expect(result2, 'tools');
      });

      test('should map electronics to electronics category', () {
        final result = service.mapLabelToCategory('laptop');
        expect(result, 'electronics');

        final result2 = service.mapLabelToCategory('phone');
        expect(result2, 'electronics');
      });

      test('should return other for unknown items', () {
        final result = service.mapLabelToCategory('unknown_item_xyz');
        expect(result, 'other');
      });

      test('should be case insensitive', () {
        final result1 = service.mapLabelToCategory('APPLE');
        final result2 = service.mapLabelToCategory('Apple');
        final result3 = service.mapLabelToCategory('apple');

        expect(result1, 'groceries');
        expect(result2, 'groceries');
        expect(result3, 'groceries');
      });
    });

    group('dispose', () {
      test('should close interpreter resources', () {
        when(mockInterpreter.close()).thenReturn(null);

        service.dispose();

        verify(mockInterpreter.close()).called(1);
      });
    });
  });
}
