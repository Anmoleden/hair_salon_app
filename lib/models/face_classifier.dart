import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

class ImageClassifier {
  static const String modelPath =
      'assets/face_classification_model/face_shape_classifier.tflite';
  static const int imgSize = 224;
  static const List<String> labels = [
    'Heart',
    'Oblong',
    'Oval',
    'Round',
    'Square',
  ];

  static bool _isModelLoaded = false;

  static Future<void> loadModel() async {
    // Mock model loading - replace with actual TFLite implementation later
    await Future.delayed(const Duration(milliseconds: 100));
    _isModelLoaded = true;
  }

  /// Classifies the given image file and returns a map with label and confidence.
  /// This is a mock implementation - replace with actual TFLite inference later.
  static Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    // Load and preprocess image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return {'error': 'Could not decode image'};
    }

    // Mock classification - replace with actual TFLite inference
    // For now, this returns a random face shape with high confidence
    final random = Random();
    final randomIndex = random.nextInt(labels.length);
    final confidence = 0.8 + (random.nextDouble() * 0.2); // 80-100% confidence

    return {'label': labels[randomIndex], 'confidence': confidence};
  }

  /// Mock method for image preprocessing - replace with actual implementation later
  static List<double> imageToByteListFloat32(
    img.Image image,
    int inputSize,
    double mean,
    double std,
  ) {
    // Mock implementation - replace with actual preprocessing
    final List<double> convertedBytes = List.filled(
      inputSize * inputSize * 3,
      0.0,
    );
    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        convertedBytes[pixelIndex++] = ((pixel.r.toDouble()) - mean) / std;
        convertedBytes[pixelIndex++] = ((pixel.g.toDouble()) - mean) / std;
        convertedBytes[pixelIndex++] = ((pixel.b.toDouble()) - mean) / std;
      }
    }
    return convertedBytes;
  }

  static void dispose() {
    _isModelLoaded = false;
  }
}
