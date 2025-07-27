import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../classifiers/hairstyle_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../services/interaction_services.dart';

class TryOnScreenPageOriginal extends StatefulWidget {
  final Hairstyle hairstyle;
  final File capturedImage;
  final bool isMale;

  const TryOnScreenPageOriginal({
    super.key,
    required this.hairstyle,
    required this.capturedImage,
    required this.isMale,
  });

  @override
  State<TryOnScreenPageOriginal> createState() => _TryOnScreenPageState();
}

class _TryOnScreenPageState extends State<TryOnScreenPageOriginal> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  Offset? _overlayPosition;
  double _hairWidth = 150;
  double _hairHeight = 150;
  bool _showOverlay = true;

  double _rotation = 0.0;
  double _scale = 1.0;
  Offset _dragOffset = Offset.zero;

  final GlobalKey _previewContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _analyzeFace(widget.capturedImage);
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  void _logTryOnEvent() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    final hairstyleId = widget.hairstyle.hairstyleId;

    if (userId == null) return;

    try {
      await InteractionService.addToHistory(userId, hairstyleId);
      print('History logged');

      await InteractionService.incrementPopularity(hairstyleId);
      print('Popularity incremented');
    } catch (e) {
      print(' Failed to log try-on: $e');
    }
  }

  Future<void> _incrementPopularity(String hairstyleId) async {
    try {
      final uri = ApiConfig.getIncrementPopularityUri(hairstyleId);
      print('Sending POST to: $uri');

      final response = await http.post(uri);

      print('Response status:${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint(' Popularity incremented');
      } else {
        debugPrint(' Failed to increment popularity: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(' Error incrementing popularity: $e');
    }
  }

  Future<void> _analyzeFace(File image) async {
    final inputImage = InputImage.fromFile(image);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first;
      final rect = face.boundingBox;
      final nose = face.landmarks[FaceLandmarkType.noseBase];

      if (nose != null) {
        final double x = nose.position.x.toDouble();
        final double y = nose.position.y.toDouble();

        //  Adjust size based on hairstyle.length and gender
        double widthFactor = 1.4;
        double heightFactor = 1.2;

        switch (widget.hairstyle.category.toLowerCase()) {
          case 'short':
            widthFactor = 1.2;
            heightFactor = 1.0;
            break;
          case 'medium':
            widthFactor = 1.4;
            heightFactor = 1.2;
            break;
          case 'long':
            widthFactor = 1.6;
            heightFactor = 1.5;
            break;
        }

        // Optional: further fine-tune based on gender
        if (widget.hairstyle.gender.toLowerCase() == 'female') {
          heightFactor += 0.1;
        }

        setState(() {
          _overlayPosition = Offset(x, y - rect.height * 0.6);
          _hairWidth = rect.width * 1.4;
          _hairHeight = rect.height * 1.2;
        });

        //log try on history
        _logTryOnEvent();

        // increment popularity try on
        // await _incrementPopularity(widget.hairstyle.hairstyleId);
      }
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
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  Future<Size> _getImageSize(File imageFile) async {
    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final hairstyleUrl =
        _showOverlay
            ? widget.hairstyle.imageUrl
            : widget.hairstyle.representingImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Try On Hairstyle"),
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.face : Icons.image),
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
                  _hairWidth / 2;
              final dy = (_overlayPosition?.dy ?? 0) * scaleY + offsetY;

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

                    // Hairstyle overlay with gestures
                    if (_overlayPosition != null && _showOverlay)
                      // if (_overlayPosition != null)
                      Positioned(
                        left: dx + _dragOffset.dx,
                        top: dy + _dragOffset.dy,
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
                              hairstyleUrl,
                              width: _hairWidth,
                              height: _hairHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                    if (!_showOverlay)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              hairstyleUrl,
                              width: 200,
                              height: 220,
                              fit: BoxFit.cover,
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
