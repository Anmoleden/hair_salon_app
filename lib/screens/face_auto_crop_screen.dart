import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceAutoCropScreen extends StatefulWidget {
  final File imageFile;
  const FaceAutoCropScreen({super.key, required this.imageFile});

  @override
  State<FaceAutoCropScreen> createState() => _FaceAutoCropScreenState();
}

class _FaceAutoCropScreenState extends State<FaceAutoCropScreen>
    with SingleTickerProviderStateMixin {
  ui.Image? _croppedUiImage;
  bool _loading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _processImage();
  }

  Future<void> _processImage() async {
    setState(() => _loading = true);
    final inputImage = InputImage.fromFile(widget.imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    final faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    if (faces.isNotEmpty) {
      final face = faces.first;
      final boundingBox = face.boundingBox;
      final bytes = await widget.imageFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original != null) {
        // Crop to face bounding box, clamp to image bounds
        final cropRect = Rect.fromLTWH(
          boundingBox.left.clamp(0, original.width.toDouble()),
          boundingBox.top.clamp(0, original.height.toDouble()),
          boundingBox.width.clamp(1, original.width - boundingBox.left),
          boundingBox.height.clamp(1, original.height - boundingBox.top),
        );
        final cropped = img.copyCrop(
          original,
          x: cropRect.left.toInt(),
          y: cropRect.top.toInt(),
          width: cropRect.width.toInt(),
          height: cropRect.height.toInt(),
        );
        final uiImage = await _imageToUiImage(cropped);
        setState(() {
          _croppedUiImage = uiImage;
          _loading = false;
        });
        _controller.forward();
        return;
      }
    }
    // If no face or decode failed, just show original
    final bytes = await widget.imageFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original != null) {
      final uiImage = await _imageToUiImage(original);
      setState(() {
        _croppedUiImage = uiImage;
        _loading = false;
      });
      _controller.forward();
    }
  }

  Future<ui.Image> _imageToUiImage(img.Image image) async {
    final pngBytes = img.encodePng(image);
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(pngBytes));
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Face Crop')),
      body: Center(
        child:
            _loading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Detecting face and cropping...'),
                  ],
                )
                : FadeTransition(
                  opacity: _fadeAnimation,
                  child:
                      _croppedUiImage != null
                          ? RawImage(image: _croppedUiImage)
                          : const Text('No face detected.'),
                ),
      ),
    );
  }
}
