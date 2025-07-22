import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  static Interpreter? _interpreter;
  static const String modelPath =
      'assets/models/face_shape_classifier_quant.tflite'; // use quantized model
  static const int imgSize = 224;
  static const List<String> labels = [
    'Heart',
    'Oblong',
    'Oval',
    'Round',
    'Square',
  ];

  static Future<void> loadModel() async {
    if (_interpreter != null) return;
    final options = InterpreterOptions()..threads = 2;
    _interpreter = await Interpreter.fromAsset(modelPath, options: options);
  }

  static Uint8List imageToUint8(img.Image image) {
    final Uint8List result = Uint8List(imgSize * imgSize * 3);
    int index = 0;
    for (int y = 0; y < imgSize; y++) {
      for (int x = 0; x < imgSize; x++) {
        final pixel = image.getPixel(x, y);
        result[index++] = pixel.r.toInt(); // raw int [0,255]
        result[index++] = pixel.g.toInt();
        result[index++] = pixel.b.toInt();
      }
    }
    return result;
  }

  static Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_interpreter == null) await loadModel();

    final img.Image? oriImage = img.decodeImage(await imageFile.readAsBytes());
    if (oriImage == null) return {'error': 'Could not decode image'};

    final img.Image resized = img.copyResize(
      oriImage,
      width: imgSize,
      height: imgSize,
    );

    final Uint8List input = imageToUint8(resized);

    // Prepare tensors
    var inputTensor = input.buffer.asUint8List();
    var outputTensor = List.filled(
      labels.length,
      0,
    ).reshape([1, labels.length]);

    // Run model
    _interpreter!.run(
      inputTensor.reshape([1, imgSize, imgSize, 3]),
      outputTensor,
    );

    // Convert output to double for confidence calculation
    List<double> probs =
        (outputTensor[0] as List).map((e) => (e as num).toDouble()).toList();

    int maxIdx = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIdx = i;
      }
    }

    return {'label': labels[maxIdx], 'confidence': maxProb, 'raw': probs};
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
