import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../config/api_config.dart';
import '../../classifiers/hairstyle_model.dart';

class TryOnHairstyles extends StatefulWidget {
  final Hairstyle hairstyle;
  final File capturedImage;
  final bool isMale;

  const TryOnHairstyles({
    super.key,
    required this.hairstyle,
    required this.capturedImage,
    required this.isMale,
  });

  @override
  State<TryOnHairstyles> createState() => _TryOnHairstylesState();
}

class _TryOnHairstylesState extends State<TryOnHairstyles> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  Offset? _overlayPosition;
  double _hairWidth = 180;
  double _hairHeight = 180;
  bool _showOverlay = true;

  double _rotation = 0.0;
  double _scale = 1.0;
  Offset _dragOffset = Offset.zero;

  final GlobalKey _previewContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resetState();
    _analyzeFace(widget.capturedImage);
    _incrementHairstylePopularity(widget.hairstyle.hairstyleId);
  }

  void _resetState() {
    _rotation = 0.0;
    _scale = 1.0;
    _dragOffset = Offset.zero;
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
        final rect = face.boundingBox;

        setState(() {
          _overlayPosition = Offset(
            rect.left + rect.width / 2,
            rect.top - 80,
          );
          _hairWidth = rect.width * 1.5;
          _hairHeight = _hairWidth;
        });
      }
    } catch (e) {
      print("Face detection error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face analysis failed. Try a clearer photo.")),
      );
    }
  }

  Future<void> _incrementHairstylePopularity(String hairstyleId) async {
    final url = ApiConfig.getIncrementPopularityUri(hairstyleId);
    try {
      await http.post(url);
    } catch (e) {
      print('Error incrementing popularity: $e');
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
          '${directory.path}/hairstyle_tryon_${DateTime.now().millisecondsSinceEpoch}.png';
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
        title: const Text("Try On Hairstyle"),
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showOverlay = !_showOverlay),
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

              final dx = (_overlayPosition?.dx ?? 0) * scaleX + offsetX - _hairWidth / 2 + _dragOffset.dx;
              final dy = (_overlayPosition?.dy ?? 0) * scaleY + offsetY - _hairHeight / 2 + _dragOffset.dy;

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
                            transform: Matrix4.identity()
                              ..rotateZ(_rotation)
                              ..scale(_scale),
                            child: Image.network(
                              widget.hairstyle.imageUrl,
                              width: _hairWidth,
                              height: _hairHeight,
                              fit: BoxFit.contain,
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

