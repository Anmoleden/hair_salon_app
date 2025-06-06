import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';

class DetectFaceShapeScreen extends StatefulWidget {
  const DetectFaceShapeScreen({super.key});

  @override
  State<DetectFaceShapeScreen> createState() => _DetectFaceShapeScreenState();
}

class _DetectFaceShapeScreenState extends State<DetectFaceShapeScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  late final FaceDetector _faceDetector;
  List<Face> _faces = [];
  bool _isDetecting = false;
  String _selectedHair = 'assets/hairs/short1.png';
  final GlobalKey _previewContainerKey = GlobalKey();

  Offset _hairOffset = const Offset(100, 150);
  bool _autoPositionHair = true;
  bool _isMale = true;
  String resultText = "Center your face in the square.";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: true,
        enableLandmarks: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final bytes = image.planes.fold<Uint8List>(
        Uint8List(0),
        (previousValue, plane) =>
            Uint8List.fromList([...previousValue, ...plane.bytes]),
      );

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final InputImageRotation rotation = InputImageRotation.rotation90deg;
      final InputImageFormat format = InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _faces = faces;
          if (faces.isNotEmpty) {
            resultText = "Face detected! Ready for face shape analysis.";
          } else {
            resultText = "No face detected.";
          }

          if (_autoPositionHair && faces.isNotEmpty) {
            final face = faces.first;
            final rect = face.boundingBox;
            _hairOffset = Offset(rect.left - 20, rect.top - 60);
          }
        });
      }
    } catch (e) {
      debugPrint("Error in face detection: $e");
    }

    _isDetecting = false;
  }

  Future<void> _captureImageWithOverlay() async {
    try {
      RenderRepaintBoundary boundary =
          _previewContainerKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getTemporaryDirectory()).path;
      final fileName = "hairstyle_${DateTime.now().millisecondsSinceEpoch}.png";
      final filePath = path.join(directory, fileName);
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(pngBytes);

      final result = await ImageGallerySaver.saveFile(imageFile.path);
      if (result != null) {
        Fluttertoast.showToast(msg: "Image saved to gallery!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving image: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hairOptions =
        _isMale
            ? ['assets/hairs/short1.png', 'assets/hairs/short2.png']
            : ['assets/hairs/long1.png', 'assets/hairs/long2.png'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detect Face Shape & Try Hairstyles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _captureImageWithOverlay,
          ),
        ],
      ),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [_isMale, !_isMale],
            onPressed: (index) {
              setState(() {
                _isMale = index == 0;
                _selectedHair = _isMale ? hairOptions[0] : hairOptions[0];
              });
            },
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text("Male")),
              Padding(padding: EdgeInsets.all(8), child: Text("Female")),
            ],
          ),
          SwitchListTile(
            title: const Text("Auto-align hair"),
            value: _autoPositionHair,
            onChanged: (value) {
              setState(() {
                _autoPositionHair = value;
              });
            },
          ),
          Expanded(
            child: RepaintBoundary(
              key: _previewContainerKey,
              child: Stack(
                children: [
                  CameraPreview(_controller!),

                  // Draw face boxes (for debug/UX)
                  ..._faces.map((face) {
                    final rect = face.boundingBox;
                    return Positioned(
                      left: rect.left,
                      top: rect.top,
                      width: rect.width,
                      height: rect.height,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),

                  Positioned(
                    left: _hairOffset.dx,
                    top: _hairOffset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        if (!_autoPositionHair) {
                          setState(() {
                            _hairOffset += details.delta;
                          });
                        }
                      },
                      child: Image.asset(
                        _selectedHair,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              resultText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hairOptions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap:
                      () => setState(() => _selectedHair = hairOptions[index]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _selectedHair == hairOptions[index]
                                ? Colors.teal
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      hairOptions[index],
                      width: 80,
                      height: 80,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
