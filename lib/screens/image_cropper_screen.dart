import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../classifiers/face_classifier.dart';
import 'try_hairstyles.dart';
import 'result_screen.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;
  final bool isTryHairstyleFlow;
  final bool isFromCamera; // Add this parameter

  const ImageCropperScreen({
    super.key,
    required this.imageFile,
    required this.isTryHairstyleFlow,
    this.isFromCamera = true, // Default to true since we're coming from camera
  });

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startCropping();
  }

  Future<void> _startCropping() async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          if (Platform.isAndroid)
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            )
          else if (Platform.isIOS)
            IOSUiSettings(
              title: 'Crop Image',
            ),
        ],
      );

      if (!mounted) return;

      if (croppedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cropping cancelled')),
        );
        Navigator.pop(context);
        return;
      }

      final croppedImageFile = File(croppedFile.path);

      // Hairstyle flow - direct navigation with both parameters
      if (widget.isTryHairstyleFlow) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TryHairstyles(
              initialImage: croppedImageFile,
              isFromCamera: widget.isFromCamera,
            ),
          ),
        );
        return;
      }

      // Face detection flow - classify then show results
      final result = await ImageClassifier.classifyImage(croppedImageFile);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            croppedFile: croppedImageFile,
            classificationResult: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (_isProcessing) const SizedBox(height: 20),
            if (_isProcessing)
              const Text(
                'Processing image...',
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}