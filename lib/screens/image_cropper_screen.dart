import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/face_classifier.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropperScreen({super.key, required this.imageFile});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  CroppedFile? _croppedFile;
  Map<String, dynamic>? _classificationResult;
  bool _isClassifying = false;

  @override
  void initState() {
    super.initState();
    _startCropping();
  }

  Future<void> _startCropping() async {
    List<PlatformUiSettings> uiSettings = [];

    if (Platform.isAndroid) {
      uiSettings.add(
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      );
    } else if (Platform.isIOS) {
      uiSettings.add(IOSUiSettings(title: 'Crop Image'));
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: uiSettings,
    );

    if (!mounted) return;

    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
        _isClassifying = true;
      });
      await ImageClassifier.loadModel();
      final result = await ImageClassifier.classifyImage(
        File(croppedFile.path),
      );
      if (!mounted) return;
      setState(() {
        _classificationResult = result;
        _isClassifying = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cropping cancelled')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_croppedFile != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cropped Image')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(_croppedFile!.path)),
              const SizedBox(height: 24),
              if (_isClassifying)
                const CircularProgressIndicator()
              else if (_classificationResult != null)
                _buildResultWidget(_classificationResult!),
            ],
          ),
        ),
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildResultWidget(Map<String, dynamic> result) {
    if (result.containsKey('error')) {
      return Text(
        'Error: ${result['error']}',
        style: const TextStyle(color: Colors.red),
      );
    }
    return Column(
      children: [
        Text(
          'Face Shape: ${result['label']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text('Confidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%'),
      ],
    );
  }
}
