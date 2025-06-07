import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropperScreen({super.key, required this.imageFile});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  CroppedFile? _croppedFile;

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
      uiSettings.add(
        IOSUiSettings(
          title: 'Crop Image',
        ),
      );
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
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cropping cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_croppedFile != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cropped Image')),
        body: Center(child: Image.file(File(_croppedFile!.path))),
      );
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
