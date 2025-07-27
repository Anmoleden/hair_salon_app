import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:hair_salon/screens/try_hairstyle_direct.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'try_hairstyles.dart';
import 'utils.dart';

class GalleryViewDirect extends StatefulWidget {
  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;
  final bool isTryHairstyleFlow;
  final String gender;
  //final String? faceShape;

  const GalleryViewDirect({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
    required this.isTryHairstyleFlow,
    required this.gender,
    //this.faceShape,
  });

  @override
  State<GalleryViewDirect> createState() => _GalleryViewDirectState();
}

class _GalleryViewDirectState extends State<GalleryViewDirect> {
  File? _image;
  ImagePicker? _imagePicker;

  // String _selectedGender = 'male';
  final String _selectedFaceShape = 'All';

  final List<String> genderOptions = ['male', 'female'];
  final List<String> faceShapeOptions = ['oval', 'round', 'square', 'heart', 'oblong'];

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();

     // Set selected gender from the passed value
  //_selectedGender = widget.gender.toLowerCase() ?? 'male';
    //_selectedGender = widget.gender.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
        //  padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 20),
             // _buildDropdowns(),
              const SizedBox(height: 20),
              _buildActionButtonsGrid(),
              const SizedBox(height: 30),
              _buildTryNowButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _image != null
            ? Image.file(_image!, fit: BoxFit.cover)
            : Padding(
              padding: const EdgeInsets.all(8.0),
            // padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox( 
                  //   height: 305,
                  //    width: 305,
                  // Expanded(
                  // child:       //   'assets/Instruct-image.png',         //   fit: BoxFit.contain,
                  //    ),
                  // ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please select or capture an image to begin.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
              ),
            ),
      ),
    );
  }

  Widget _buildActionButtonsGrid() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSquareButton('Gallery', Icons.photo_library, () => _getImage(ImageSource.gallery)),
        _buildSquareButton('Camera', Icons.camera_alt, () => _getImage(ImageSource.camera)),
        _buildSquareButton('Samples', Icons.photo_album, () => _getImageAsset()),
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
            color: Colors.white, // white background like GalleryView
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300), // subtle border
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.black54), // grey icon
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


  Widget _buildTryNowButton() {
    return ElevatedButton.icon(
      onPressed: _image != null ? _goToTryHairstyles : null,
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('Try Hairstyle', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(184, 85, 125, 212),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }

  void _goToTryHairstyles() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TryHairstyles(
          initialImage: _image!,
          isFromCamera: false, // if this variable exists in the context
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
  final pickedFile = await _imagePicker?.pickImage(source: source);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path); 
    });
  }
}


  Future<void> _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((key) => key.contains('images/'))
        .where((key) =>
            key.endsWith('.jpg') ||
            key.endsWith('.jpeg') ||
            key.endsWith('.png') ||
            key.endsWith('.webp'))
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
            Text('Select Sample Image', style: Theme.of(context).textTheme.titleLarge),
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
              child: const Text('CANCEL', style: TextStyle(color: Colors.pinkAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(String path) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(path, width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(path.split('/').last),
      onTap: () async {
        Navigator.pop(context);
        final file = await getAssetPath(path);
        setState(() => _image = File(file));
      },
    );
  }
}

 