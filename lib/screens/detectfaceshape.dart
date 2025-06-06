import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'dart:io';

class DetectFaceShapeScreen extends StatefulWidget {
  const DetectFaceShapeScreen({super.key});

  @override
  State<DetectFaceShapeScreen> createState() => _DetectFaceShapeScreenState();
}

class _DetectFaceShapeScreenState extends State<DetectFaceShapeScreen> {
  late FaceCameraController controller;
  String resultText = "Center your face in the square.";

  @override
  void initState() {
    super.initState();
    controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) async {
        if (image == null) {
          setState(() => resultText = "No image captured.");
          return;
        }

        await detectFaceShape(image);
      },
    );
  }

  Future<void> detectFaceShape(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    );
    final faceDetector = FaceDetector(options: options);

    final faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      setState(
        () => resultText = "Face detected! Ready for face shape analysis.",
      );
    } else {
      setState(() => resultText = "No face detected.");
    }

    faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detect Face Shape")),
      body: Column(
        children: [
          Expanded(
            child: SmartFaceCamera(
              controller: controller,
              message: 'Center your face in the square',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              resultText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
