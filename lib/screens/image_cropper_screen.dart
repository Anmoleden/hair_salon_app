import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../classifiers/face_classifier.dart';
import 'result_screen.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;
  final bool isTryHairstyleFlow;
  final Uint8List? capturedImage;
  final String gender;
  //final bool isMale;
  //final Hairstyle? selectedHairstyle;

  const ImageCropperScreen({
    super.key,
    required this.imageFile,
    required this.isTryHairstyleFlow,
    this.capturedImage,
    required this.gender,
    //this.croppedImage,
    //required this.isMale,
    // required this.selectedHairstyle,
  });

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  CroppedFile? _croppedFile;
  Map<String, dynamic>? _classificationResult;
  // String? _genderResult;
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
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
      );
    } else if (Platform.isIOS) {
      uiSettings.add(
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          minimumAspectRatio: 1.0,
        ),
      );
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: uiSettings,
    );

    if (croppedFile != null) {
      // Read bytes from cropped file BEFORE using it
      final bytes = await File(croppedFile.path).readAsBytes();
      if (widget.isTryHairstyleFlow) {
        if (!mounted) return;
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (context) => TryHairstylesOriginal(
        //           croppedImage: File(croppedFile.path),
        //         //  capturedImage: bytes,
        //         ),
        //     // hairstyle: selectedHairstyle,
        //     // capturedImage: croppedFile,
        //     // isMale: widget.isMale // or false based on gender
        //   ),
        // );
        //return;
      } else {
        setState(() {
          _croppedFile = croppedFile;
          _isClassifying = true;
        });
        try {
          print('Starting classification...');
          final faceShapeResult = await ImageClassifier.classifyImage(
            File(croppedFile.path),
          );
          // final genderResult = await GenderClassifier.classify(
          // File(croppedFile.path),
          //);

          final classificationResult = {
            'label': faceShapeResult['label'],
            'confidence': faceShapeResult['confidence'],
            // 'gender': genderResult['gender'],
            // 'genderConfidence': genderResult['confidence'],
          };
          print('Classification result: $classificationResult');
          if (!mounted) return;
          setState(() {
            _classificationResult = classificationResult;
            _isClassifying = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultScreen(
                    croppedFile: File(croppedFile.path),
                    classificationResult: classificationResult,
                    gender: widget.gender,
                  ),
            ),
          );
        } catch (e, stack) {
          print('Classification error: $e');
          print(stack);
          setState(() {
            _classificationResult = {'error': e.toString()};
            _isClassifying = false;
          });
        }
      }
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Cropped Image',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(_croppedFile!.path)),
              const SizedBox(height: 24),
              if (_isClassifying) const CircularProgressIndicator(),
              // else if (_classificationResult != null)
              //   _buildResultWidget(_classificationResult!),
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
        // if (_genderResult != null)
        //   Text('Gender: $_genderResult', style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
