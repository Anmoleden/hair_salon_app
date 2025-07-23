import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class TryHairstyles extends StatefulWidget {
  final File initialImage;
  final bool isFromCamera;

  const TryHairstyles({
    super.key, 
    required this.initialImage,
    this.isFromCamera = false,
  });

  @override
  State<TryHairstyles> createState() => _TryHairstylesState();
}

class _TryHairstylesState extends State<TryHairstyles>
    with TickerProviderStateMixin {
  late final FaceDetector _faceDetector;
  List<Face> _faces = [];
  late File _capturedImage;
  File? _processedImage;

  bool _isMale = true;
  bool _autoAlignHair = true;
  String selectedCategory = "Short";
  int _selectedBottomTab = 0;
  bool _isProcessing = false;

  Offset _hairOffset = const Offset(100, 150);
  double _hairScaleX = 1.0;
  double _hairScaleY = 1.0;
  double _hairRotation = 0.0;
  bool _isHairBeingEdited = false;
  bool _isRotating = false;

  final GlobalKey _imageKey = GlobalKey();
  String resultText = "Adjust your hairstyle";
  String _selectedHair = '';
  String _selectedGlasses = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Offset? _rotationStartVector;
  double _initialRotation = 0;
  Offset? _rotationCenter;
  double _initialScale = 1.0;
  Offset _initialOffset = Offset.zero;

  final Map<String, List<String>> maleHairs = {
    "Oval": ['assets/hairs/short1.png', 'assets/hairs/short2.png'],
    "Round": ['assets/hairs/med1.png', 'assets/hairs/med2.png'],
    "Square": ['assets/hairs/long1.png'],
     "Heart": ['assets/hairs/long1.png'],
      "Oblong": ['assets/hairs/long1.png'],
  };

  final Map<String, List<String>> femaleHairs = {
    "Oval": ['assets/hairs/f_short1.png'],
    "Round": ['assets/hairs/f_med1.png'],
    "Square": ['assets/hairs/f_long1.png', 'assets/hairs/f_long2.png'],
    "Heart": ['assets/hairs/f_med1.png'],
    "Oblong": ['assets/hairs/f_med1.png'],
  };

  final List<String> glassesList = [
    'assets/glasses/glass1.png',
    'assets/glasses/glass2.png',
  ];

  List<String> get currentHairOptions =>
      _isMale ? maleHairs[selectedCategory] ?? [] : femaleHairs[selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _capturedImage = widget.initialImage;
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
    _initializeFaceDetection();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  Future<File> _fixImageOrientation(File file) async {
    try {
      final byteData = await file.readAsBytes();
      Uint8List bytes = byteData.buffer.asUint8List();
      
      // Decode the image
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) return file;

      // Handle EXIF orientation for camera photos
      if (widget.isFromCamera) {
        originalImage = img.copyRotate(originalImage, angle: 0); // Reset orientation
      }

      // Resize to reasonable dimensions while maintaining aspect ratio
      const maxWidth = 1000;
      final ratio = maxWidth / originalImage.width;
      final height = (originalImage.height * ratio).round();

      final fixedImage = img.copyResize(
        originalImage,
        width: maxWidth,
        height: height,
        maintainAspect: true,
      );

      final tempDir = await getTemporaryDirectory();
      final fixedFile = File(
        '${tempDir.path}/fixed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await fixedFile.writeAsBytes(img.encodeJpg(fixedImage));

      return fixedFile;
    } catch (e) {
      debugPrint('Error fixing image orientation: $e');
      return file;
    }
  }

  Future<void> _initializeFaceDetection() async {
    if (mounted) {
      setState(() {
        _isProcessing = true;
        resultText = "Processing image...";
      });
    }

    try {
      _processedImage = await _fixImageOrientation(_capturedImage);
      final inputImage = InputImage.fromFile(_processedImage!);
      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _faces = faces;
          resultText = faces.isEmpty
              ? "No face found. Position hair manually."
              : "Face detected! Adjust your hairstyle.";

          if (_autoAlignHair && faces.isNotEmpty) {
            final face = faces.first;
            final rect = face.boundingBox;
            _hairOffset = Offset(
              rect.left - 20,
              rect.top - 60,
            );
            _hairScaleX = 1.0;
            _hairScaleY = 1.0;
            _hairRotation = 0.0;
          } else {
            _resetHairPositionToCenter();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => resultText = "Error processing image: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _resetHairPositionToCenter() {
    final context = _imageKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final size = box.size;
        setState(() {
          _hairOffset = Offset(size.width / 2 - 60, size.height / 2 - 60);
          _hairScaleX = 1.0;
          _hairScaleY = 1.0;
          _hairRotation = 0.0;
          _isHairBeingEdited = true;
        });
      }
    }
  }

  Future<void> _saveImage() async {
    try {
      if (_selectedHair.isEmpty) return;

      final boundary = _imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/hairstyle_$timestamp.png';
      await File(imagePath).writeAsBytes(pngBytes);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success'),
            content: Text('Image saved successfully at:\n$imagePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Failed'),
            content: Text('Failed to save image:\n${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openPanel(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _buildPanelContent(type, setModalState),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPanelContent(
    String type,
    void Function(void Function()) setModalState,
  ) {
    switch (type) {
      case "Hair":
        return Column(
          children: [
            _buildCategoryTabs(setModalState),
            const SizedBox(height: 10),
            Expanded(child: _buildHairSelectorGrid()),
          ],
        );
      case "Glasses":
        return _buildGlassesGrid(setModalState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildCategoryTabs(void Function(void Function()) setModalState) {
    final Map<String, List<String>> hairMap = _isMale ? maleHairs : femaleHairs;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hairMap.keys.map((category) {
          final selected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (isSelected) {
                setModalState(() {
                  selectedCategory = category;
                  _selectedHair = '';
                });
                setState(() {});
              },
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHairSelectorGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: currentHairOptions.map((hair) {
        final selected = hair == _selectedHair;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _fadeController.reset();
            setState(() {
              _selectedHair = hair;
              _isHairBeingEdited = true;
            });
            _fadeController.forward();

            if (_autoAlignHair && _faces.isNotEmpty) {
              final face = _faces.first;
              final rect = face.boundingBox;
              _hairOffset = Offset(
                rect.left - 20,
                rect.top - 60,
              );
              _hairScaleX = 1.0;
              _hairScaleY = 1.0;
              _hairRotation = 0.0;
            } else {
              _resetHairPositionToCenter();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.teal : Colors.grey,
                width: selected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(hair, fit: BoxFit.contain),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlassesGrid(void Function(void Function()) setModalState) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: glassesList.map((glass) {
        final selected = glass == _selectedGlasses;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setModalState(() {
              _selectedGlasses = selected ? '' : glass;
            });
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.teal : Colors.grey,
                width: selected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(glass, fit: BoxFit.contain),
          ),
        );
      }).toList(),
    );
  }

  double _angleBetweenVectors(Offset v1, Offset v2) {
    final angle1 = math.atan2(v1.dy, v1.dx);
    final angle2 = math.atan2(v2.dy, v2.dx);
    return angle2 - angle1;
  }

  void _resizeHair(String handle, DragUpdateDetails details) {
    const double minSize = 50;
    const double maxSize = 400;
    double boxWidth = 160 * _hairScaleX;
    double boxHeight = 160 * _hairScaleY;
    Offset newOffset = _hairOffset;

    double widthChange = 0;
    double heightChange = 0;

    switch (handle) {
      case 'topLeft':
        widthChange = -details.delta.dx;
        heightChange = -details.delta.dy;
        newOffset += Offset(details.delta.dx, details.delta.dy);
        break;
      case 'top':
        heightChange = -details.delta.dy;
        newOffset += Offset(0, details.delta.dy);
        break;
      case 'topRight':
        widthChange = details.delta.dx;
        heightChange = -details.delta.dy;
        newOffset += Offset(0, details.delta.dy);
        break;
      case 'right':
        widthChange = details.delta.dx;
        break;
      case 'bottomRight':
        widthChange = details.delta.dx;
        heightChange = details.delta.dy;
        break;
      case 'bottom':
        heightChange = details.delta.dy;
        break;
      case 'bottomLeft':
        widthChange = -details.delta.dx;
        heightChange = details.delta.dy;
        newOffset += Offset(details.delta.dx, 0);
        break;
      case 'left':
        widthChange = -details.delta.dx;
        newOffset += Offset(details.delta.dx, 0);
        break;
    }

    double newWidth = boxWidth + widthChange;
    double newHeight = boxHeight + heightChange;

    // Constrain to min/max sizes
    newWidth = newWidth.clamp(minSize, maxSize);
    newHeight = newHeight.clamp(minSize, maxSize);

    // Adjust offset if we hit size constraints
    if (newWidth == minSize || newWidth == maxSize) {
      newOffset = Offset(
        _initialOffset.dx + (boxWidth - newWidth) * (widthChange < 0 ? 1 : 0),
        newOffset.dy,
      );
    }
    if (newHeight == minSize || newHeight == maxSize) {
      newOffset = Offset(
        newOffset.dx,
        _initialOffset.dy + (boxHeight - newHeight) * (heightChange < 0 ? 1 : 0),
      );
    }

    setState(() {
      _hairOffset = newOffset;
      _hairScaleX = newWidth / 160;
      _hairScaleY = newHeight / 160;
    });
  }

  List<Widget> _buildResizeHandles(double boxWidth, double boxHeight) {
    const double handleSize = 24.0;

    final handles = <Map<String, dynamic>>[
      {'name': 'topLeft', 'left': 0.0, 'top': 0.0},
      {'name': 'top', 'left': boxWidth / 2 - handleSize / 2, 'top': 0.0},
      {'name': 'topRight', 'left': boxWidth - handleSize, 'top': 0.0},
      {
        'name': 'right',
        'left': boxWidth - handleSize,
        'top': boxHeight / 2 - handleSize / 2,
      },
      {
        'name': 'bottomRight',
        'left': boxWidth - handleSize,
        'top': boxHeight - handleSize,
      },
      {
        'name': 'bottom',
        'left': boxWidth / 2 - handleSize / 2,
        'top': boxHeight - handleSize,
      },
      {'name': 'bottomLeft', 'left': 0.0, 'top': boxHeight - handleSize},
      {'name': 'left', 'left': 0.0, 'top': boxHeight / 2 - handleSize / 2},
    ];

  return handles.map((handle) {
      return Positioned(
        left: handle['left'],
        top: handle['top'],
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) {
            _resizeHair(handle['name'], details);
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.yellow,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Hairstyle Try-On"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 8),
                  _buildGenderToggle(),
                  const SizedBox(height: 8),
                  _buildImagePreview(),
                  const SizedBox(height: 6),
                  Text(
                    resultText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        onTap: (index) {
          setState(() => _selectedBottomTab = index);
          if (index == 0) _openPanel("Hair");
          if (index == 1) _openPanel("Glasses");
          if (index == 2) _openPanel("Editor");
        },
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Hairstyle"),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            label: "Glasses",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Editor"),
        ],
      ),
    );
  }

  Widget _buildGenderToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          isSelected: [_isMale, !_isMale],
          onPressed: (index) {
            setState(() {
              _isMale = index == 0;
              selectedCategory = "Short";
              _selectedHair = '';
            });
          },
          borderRadius: BorderRadius.circular(25),
          selectedColor: Colors.white,
          fillColor: Colors.teal,
          constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
          children: const [
            Text("Male", style: TextStyle(fontSize: 16)),
            Text("Female", style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Expanded(
      child: Center(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double boxWidth = 160 * _hairScaleX;
                double boxHeight = 160 * _hairScaleY;

                return RepaintBoundary(
                  key: _imageKey,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: InteractiveViewer(
                          panEnabled: false,
                          minScale: 0.5,
                          maxScale: 2.0,
                          child: Image.file(
                            _processedImage ?? _capturedImage,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      if (_selectedHair.isNotEmpty)
                        Positioned(
                          left: _hairOffset.dx,
                          top: _hairOffset.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              if (!_isRotating) {
                                setState(() {
                                  _hairOffset += details.delta;
                                });
                              }
                            },
                            child: Transform.rotate(
                              angle: _hairRotation,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: boxWidth,
                                    height: boxHeight,
                                    decoration:
                                        _isHairBeingEdited
                                            ? BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                  255,
                                                  59,
                                                  193,
                                                  255,
                                                ),
                                                width: 3,
                                              ),
                                            )
                                            : null,
                                    child: ClipRect(
                                      child: Image.asset(
                                        _selectedHair,
                                        fit: BoxFit.cover,
                                        width: boxWidth,
                                        height: boxHeight,
                                      ),
                                    ),
                                  ),
                                  if (_isHairBeingEdited)
                                    ..._buildResizeHandles(boxWidth, boxHeight),
                                  if (_isHairBeingEdited)
                                    Positioned(
                                      right: -14,
                                      bottom: -14,
                                      child: Listener(
                                        behavior: HitTestBehavior.translucent,
                                        onPointerDown: (details) {
                                          final renderBox =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final center = renderBox
                                              .localToGlobal(
                                                Offset(
                                                  boxWidth / 2,
                                                  boxHeight / 2,
                                                ),
                                              );
                                          setState(() {
                                            _isRotating = true;
                                            _rotationCenter = center;
                                            _rotationStartVector =
                                                details.position - center;
                                            _initialRotation = _hairRotation;
                                          });
                                        },
                                        onPointerMove: (details) {
                                          if (!_isRotating ||
                                              _rotationCenter == null ||
                                              _rotationStartVector == null) {
                                            return;
                                          }

                                          final currentVector =
                                              details.position -
                                              _rotationCenter!;
                                          final angle = _angleBetweenVectors(
                                            _rotationStartVector!,
                                            currentVector,
                                          );

                                          setState(() {
                                            _hairRotation =
                                                _initialRotation + angle;
                                          });
                                        },
                                        onPointerUp: (_) {
                                          setState(() => _isRotating = false);
                                        },
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 2,
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.rotate_right,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_isHairBeingEdited)
                                    Positioned(
                                      right: -14,
                                      top: -14,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap:
                                            () => setState(
                                              () => _isHairBeingEdited = false,
                                            ),
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 2,
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (_selectedHair.isNotEmpty && !_isHairBeingEdited)
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.teal,
                  onPressed: _saveImage,
                  child: const Icon(Icons.save, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
