import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../classifiers/face_classifier.dart';
import 'recommendation_page.dart';

class FaceDetectionScreen extends StatefulWidget {
  final File capturedImage;
  final String gender;

  const FaceDetectionScreen({
    super.key,
    required this.capturedImage,
    required this.gender,
  });

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Call detection AFTER the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectFaceAndNavigate();
    });
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaceAndNavigate() async {
    try {
      final inputImage = InputImage.fromFile(widget.capturedImage);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final prediction = await ImageClassifier.classifyImage(widget.capturedImage);
        final faceShape = prediction['label'] ?? "Unknown";

        debugPrint("✅ Detected face shape: $faceShape");

        if (!_navigated && faceShape != "Unknown" && mounted) {
          _navigated = true;

          // Navigate after the current build frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RecommendationPage(
                  faceShape: faceShape,
                  gender: widget.gender,
                  capturedImage: widget.capturedImage,
                ),
              ),
            );
          });
        } else if (faceShape == "Unknown") {
          _showMessage("Face shape could not be recognized. Try again.");
        }
      } else {
        _showMessage("No face detected in the image.");
      }
    } catch (e) {
      debugPrint("❌ Face detection error: $e");
      _showMessage("Error detecting face: $e");
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
    );
  }
}
