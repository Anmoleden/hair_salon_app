import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hair_salon/screens/image_cropper_screen.dart';
import 'sample_image_screen.dart';
import 'utils.dart';

class GalleryView extends StatefulWidget {
  final bool isTryHairstyleFlow;

  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
    required this.isTryHairstyleFlow,
    required this.gender,
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;
  final String gender;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  ImagePicker? _imagePicker;
  String _faceResult = '';
  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(38),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: widget.onDetectorViewModeChanged,
            ),
          ],
          toolbarHeight: 38,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildImagePreview(),
            ),
          ),
          _buildResultDisplay(),
          const SizedBox(height: 12),
          _buildActionButtonsGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          _image != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.contain),
              )
              : Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Image.asset(
                          'assets/Instruct-image.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please select or capture an image to begin.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildResultDisplay() {
    if (_faceResult.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                _faceResult.contains('No face')
                    ? Colors.orange[100]
                    : Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _faceResult,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  _faceResult.contains('No face')
                      ? Colors.orange[800]
                      : Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSquareButton(
            'Gallery',
            Icons.photo_library,
            () => _getImage(ImageSource.gallery),
          ),
          _buildSquareButton(
            'Camera',
            Icons.camera_alt,
            () => _getImage(ImageSource.camera),
          ),
          _buildSquareButton(
            'Samples', 
            Icons.photo_album, _getImageAsset),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.black54),
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _faceResult = '';
    });

    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future<void> _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets =
        manifestMap.keys
            .where((key) => key.contains('samples/'))
            .where(
              (key) =>
                  key.endsWith('.jpg') ||
                  key.endsWith('.jpeg') ||
                  key.endsWith('.png') ||
                  key.endsWith('.webp'),
            )
            .toList();

    if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SampleImagesPage(
        assets: assets,
        onImageSelected: (String path) async {
          Navigator.pop(context);
          _processFile(await getAssetPath(path));
        },
      ),
    ),
  );
}

  Widget _buildAssetItem(String path) {
    return ListTile(
      leading: Image.asset(path, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(path.split('/').last),
      onTap: () async {
        Navigator.pop(context);
        _processFile(await getAssetPath(path));
      },
    );
  }

  Future<void> _processFile(String path) async {
    setState(() {
      _image = File(path);
      _faceResult = 'Analyzing...';
    });

    try {
      final inputImage = InputImage.fromFilePath(path);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _faceResult =
            faces.isEmpty
                ? 'No faces detected'
                : '${faces.length} ${faces.length == 1 ? 'face' : 'faces'} detected';
      });

      widget.onImage(inputImage);

      // if (_image != null && faces.isNotEmpty) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder:
      //             (context) => ImageCropperScreen(
      //               imageFile: _image!,
      //               isTryHairstyleFlow: widget.isTryHairstyleFlow,
      //             // isMale: widget.isMale,
      //            //   selectedHairstyle: widget.selectedHairstyle,
      //             ),
      //       ),
      //     );
      //   });
      // }
      if (_image != null && faces.isNotEmpty) {
        if (widget.isTryHairstyleFlow) {
          // Navigate to TryHairstyles if in hairstyle flow
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (context) => TryHairstyles(
          //          initialImage: _image!,
          //          gender: widget.gender,
          //          faceShape: widget.faceShape,
          //         ),
          //   ),
          // );
        } else {
          // Navigate to ImageCropperScreen for face shape detection
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ImageCropperScreen(
                    imageFile: _image!,
                    gender: widget.gender,
                    isTryHairstyleFlow: widget.isTryHairstyleFlow,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _faceResult = 'Error processing image');
    }
  }
}
