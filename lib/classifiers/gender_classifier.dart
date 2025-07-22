import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class GenderClassifier {
  static Interpreter? _interpreter;
  static const int inputSize = 256;
  static const String modelPath =
      'assets/models/gender_classification_model.tflite';

  static Future<void> loadModel() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(modelPath);
  }

  static Future<Map<String, dynamic>> classify(File imageFile) async {
    if (_interpreter == null) await loadModel();
    final img.Image? oriImage = img.decodeImage(await imageFile.readAsBytes());
    if (oriImage == null) {
      return {'error': 'Invalid image'};
    }
    final img.Image resized = img.copyResize(
      oriImage,
      width: inputSize,
      height: inputSize,
    );
    var input = List.generate(
      inputSize,
      (y) => List.generate(inputSize, (x) => List.filled(3, 0.0)),
    );
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[y][x][0] = pixel.r / 255.0;
        input[y][x][1] = pixel.g / 255.0;
        input[y][x][2] = pixel.b / 255.0;
      }
    }
    var inputTensor = [input];
    var outputTensor = List.generate(1, (_) => List.filled(1, 0.0));
    _interpreter!.run(inputTensor, outputTensor);
    double prediction = outputTensor[0][0];
    String gender = prediction < 0.5 ? 'Female' : 'Male';
    double confidence = prediction < 0.5 ? 1 - prediction : prediction;
    return {'gender': gender, 'confidence': confidence, 'raw': prediction};
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
