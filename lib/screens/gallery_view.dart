import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hair_salon/screens/image_cropper_screen.dart';
import 'utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
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
    final bool showCropButton =
        _faceResult.startsWith('1 face') && _image != null;

    return Scaffold(
      appBar: AppBar(
        // Using a gradient color for the AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff4081), Color(0xFFff80ab)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
            ),
            onPressed: widget.onDetectorViewModeChanged,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2193b0),
                  Color(0xFF6dd5ed),
                ], // Bluish gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildBody(),
          if (showCropButton)
            Positioned(
              bottom: 32,
              right: 32,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ImageCropperScreen(imageFile: _image!),
                    ),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFff4081), Color(0xFFff80ab)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 24),
          _buildResultDisplay(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildPathInfo(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          _image != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
              : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
    );
  }

  Widget _buildResultDisplay() {
    if (_faceResult.isEmpty) return const SizedBox.shrink();

    // Remove the old crop button logic here!
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          'Pick from Gallery',
          Icons.photo_library,
          () => _getImage(ImageSource.gallery),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          'Take a Picture',
          Icons.camera_alt,
          () => _getImage(ImageSource.camera),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          'Choose Sample Image',
          Icons.photo_album,
          _getImageAsset,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildPathInfo() {
    return const SizedBox.shrink();
    // This widget can be used to display the file path or any other information
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
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
            .where((key) => key.contains('images/'))
            .where(
              (key) =>
                  key.endsWith('.jpg') ||
                  key.endsWith('.jpeg') ||
                  key.endsWith('.png') ||
                  key.endsWith('.webp'),
            )
            .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _buildAssetDialog(assets),
    );
  }

  Widget _buildAssetDialog(List<String> assets) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Sample Image',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assets.length,
                itemBuilder: (context, index) => _buildAssetItem(assets[index]),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
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
      _path = path;
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
    } catch (e) {
      setState(() => _faceResult = 'Error processing image');
    }
  }
}
