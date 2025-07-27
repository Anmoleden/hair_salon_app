import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

class TryOnGlassesScreen extends StatefulWidget {
  final File capturedImage;
  final String
  glassesImageUrl; // URL or local asset path of glasses PNG with transparency

  const TryOnGlassesScreen({
    super.key,
    required this.capturedImage,
    required this.glassesImageUrl,
  });

  @override
  State<TryOnGlassesScreen> createState() => _TryOnGlassesScreenState();
}

class _TryOnGlassesScreenState extends State<TryOnGlassesScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  Offset? _overlayPosition;
  double _glassesWidth = 150;
  double _glassesHeight = 75; // Usually glasses height is less than width
  bool _showOverlay = true;

  double _rotation = 0.0;
  double _scale = 1.0;
  Offset _dragOffset = Offset.zero;

  final GlobalKey _previewContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //added part
    _resetState();
    _analyzeFace(widget.capturedImage);
  }

  //added part
  void _resetState() {
    _rotation = 0.0;
    _scale = 1.0;
    _dragOffset = Offset.zero;
    //added part
    _overlayPosition = null;
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _analyzeFace(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;

        final leftEye = face.landmarks[FaceLandmarkType.leftEye];
        final rightEye = face.landmarks[FaceLandmarkType.rightEye];
        final noseBridge = face.landmarks[FaceLandmarkType.noseBase];

        if (leftEye != null && rightEye != null && noseBridge != null) {
          final left = leftEye.position;
          final right = rightEye.position;
          final nose = noseBridge.position;

          // Center glasses roughly between eyes horizontally, and a bit above nose vertically
          final centerX = (left.x + right.x) / 2;
          final centerY = (left.y + right.y) / 2;

          final eyeDistance = (right.x - left.x).abs();

          setState(() {
            _overlayPosition = Offset(centerX, centerY);
            _glassesWidth =
                eyeDistance * 2.2; // Adjust multiplier for natural fit
            _glassesHeight =
                _glassesWidth * 0.5; // Adjust height ratio as needed
          });
        }
      }
    } catch (e) {
      print("Face detection error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face analysis failed. Try a clearer photo.")),
      );
    }
  }

  Future<void> _saveCurrentScreen() async {
    try {
      RenderRepaintBoundary boundary =
          _previewContainerKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/glasses_tryon_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath)..writeAsBytesSync(pngBytes);

      await GallerySaver.saveImage(imageFile.path);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image saved to gallery.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
    }
  }

  Future<Size> _getImageSize(File imageFile) async {
    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Try On Glasses"),
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() => _showOverlay = !_showOverlay);
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveCurrentScreen,
          ),
        ],
      ),
      body: FutureBuilder<Size>(
        future: _getImageSize(widget.capturedImage),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final imageSize = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              final imageRatio = imageSize.width / imageSize.height;
              final screenRatio = screenWidth / screenHeight;

              double renderedImageWidth;
              double renderedImageHeight;

              if (imageRatio > screenRatio) {
                renderedImageWidth = screenWidth;
                renderedImageHeight = screenWidth / imageRatio;
              } else {
                renderedImageHeight = screenHeight;
                renderedImageWidth = screenHeight * imageRatio;
              }

              final offsetX = (screenWidth - renderedImageWidth) / 2;
              final offsetY = (screenHeight - renderedImageHeight) / 2;

              final scaleX = renderedImageWidth / imageSize.width;
              final scaleY = renderedImageHeight / imageSize.height;

              final dx =
                  (_overlayPosition?.dx ?? 0) * scaleX +
                  offsetX -
                  _glassesWidth / 2 +
                  _dragOffset.dx;
              final dy =
                  (_overlayPosition?.dy ?? 0) * scaleY +
                  offsetY -
                  _glassesHeight / 2 +
                  _dragOffset.dy;

              return RepaintBoundary(
                key: _previewContainerKey,
                child: Stack(
                  children: [
                    Center(
                      child: Image.file(
                        widget.capturedImage,
                        fit: BoxFit.contain,
                        width: renderedImageWidth,
                        height: renderedImageHeight,
                      ),
                    ),
                    if (_overlayPosition != null && _showOverlay)
                      Positioned(
                        left: dx,
                        top: dy,
                        child: GestureDetector(
                          onScaleUpdate: (details) {
                            setState(() {
                              _scale = details.scale;
                              _rotation = details.rotation;
                              _dragOffset += details.focalPointDelta;
                            });
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.identity()
                                  ..translate(0.0, 0.0)
                                  ..rotateZ(_rotation)
                                  ..scale(_scale),
                            child: Image.network(
                              widget.glassesImageUrl,
                              width: _glassesWidth,
                              height: _glassesHeight,
                              fit: BoxFit.contain,
                              //added part
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
