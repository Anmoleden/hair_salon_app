import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
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

  late Interpreter _interpreter;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(modelPath);
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    // Decode image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return {'error': 'Image decoding failed'};
    }

    final processedImage = preprocessImage(image);

    // Convert image to input tensor
    var input =
        imageToByteListFloat32(
          processedImage,
          imgSize,
          127.5,
          127.5,
        ).buffer.asFloat32List();

    // Prepare input/output tensors
    var inputTensor = input.reshape([1, imgSize, imgSize, 3]);
    var outputTensor = List.filled(
      labels.length,
      0.0,
    ).reshape([1, labels.length]);

    // Run inference
    _interpreter.run(inputTensor, outputTensor);

    final output = outputTensor[0];

    // Find the highest confidence result
    int predictedIndex = 0;
    double maxConfidence = output[0];
    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxConfidence) {
        maxConfidence = output[i];
        predictedIndex = i;
      }
    }

    return {'label': labels[predictedIndex], 'confidence': maxConfidence};
  }

  img.Image preprocessImage(img.Image image) {
    img.Image resizedImage = img.copyResize(
      image,
      width: imgSize,
      height: imgSize,
    );
    return resizedImage;
  }

  Float32List imageToByteListFloat32(
    img.Image image,
    int inputSize,
    double mean,
    double std,
  ) {
    final floatList = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        floatList[index++] = (r - mean) / std;
        floatList[index++] = (g - mean) / std;
        floatList[index++] = (b - mean) / std;
      }
    }

    return floatList;
  }

  void dispose() {
    _interpreter.close();
  }
}
