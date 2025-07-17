import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'take_photo_page.dart';

class TryHairstyles extends StatefulWidget {
  const TryHairstyles({super.key});

  @override
  State<TryHairstyles> createState() => _TryHairstylesState();
}

class _TryHairstylesState extends State<TryHairstyles>
    with TickerProviderStateMixin {
  List<CameraDescription>? _cameras;
  late final FaceDetector _faceDetector;
  List<Face> _faces = [];
  File? _capturedImage;

  bool _isMale = true;
  bool _autoAlignHair = true;
  String selectedCategory = "Short";
  int _selectedBottomTab = 0;

  Offset _hairOffset = const Offset(100, 150);
  double _hairScaleX = 1.0;
  double _hairScaleY = 1.0;
  double _hairRotation = 0.0;
  bool _isHairBeingEdited = false;
  bool _isRotating = false;

  final GlobalKey _imageKey = GlobalKey();
  String resultText = "Tap the camera icon to take a photo.";
  String _selectedHair = '';
  String _selectedGlasses = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Rotation handling
  Offset? _rotationStartVector;
  double _initialRotation = 0;
  Offset? _rotationCenter;

  final Map<String, List<String>> maleHairs = {
    "Short": ['assets/hairs/short1.png', 'assets/hairs/short2.png'],
    "Medium": ['assets/hairs/med1.png', 'assets/hairs/med2.png'],
    "Long": ['assets/hairs/long1.png'],
  };

  final Map<String, List<String>> femaleHairs = {
    "Short": ['assets/hairs/f_short1.png'],
    "Medium": ['assets/hairs/f_med1.png'],
    "Long": ['assets/hairs/f_long1.png', 'assets/hairs/f_long2.png'],
  };

  final List<String> glassesList = [
    'assets/glasses/glass1.png',
    'assets/glasses/glass2.png',
  ];

  List<String> get currentHairOptions =>
      _isMale
          ? maleHairs[selectedCategory] ?? []
          : femaleHairs[selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
  }

  Future<void> _captureFromCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        resultText = "No cameras found on this device.";
      });
      return;
    }

    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    final image = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => TakePhotoPage(camera: frontCamera)),
    );

    if (image != null) {
      final inputImage = InputImage.fromFile(image);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _capturedImage = image;
        _faces = faces;
        resultText =
            faces.isEmpty
                ? "No face found. Try again."
                : "Face detected! Drag, resize or rotate hair.";

        if (_autoAlignHair && faces.isNotEmpty) {
          final face = faces.first;
          final rect = face.boundingBox;
          _hairOffset = Offset(rect.left - 20, rect.top - 60);
          _hairScaleX = 1.0;
          _hairScaleY = 1.0;
          _hairRotation = 0.0;
          _isHairBeingEdited = true;
        } else {
          _resetHairPositionToCenter();
        }
      });
    }
  }

  void _resetHairPositionToCenter() {
    final context = _imageKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
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

  Future<void> _saveImage() async {
    try {
      if (_capturedImage == null || _selectedHair.isEmpty) return;

      final boundary =
          _imageKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/hairstyle_$timestamp.png';
      await File(imagePath).writeAsBytes(pngBytes);

      // ✅ Success Dialog
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
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
        // ❌ Failed Dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
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
        return _buildSettings();
    }
  }

  Widget _buildCategoryTabs(void Function(void Function()) setModalState) {
    final Map<String, List<String>> hairMap = _isMale ? maleHairs : femaleHairs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          hairMap.keys.map((category) {
            final selected = selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  selectedCategory = category;
                  _selectedHair = '';
                });
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? Colors.teal[600] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.teal : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHairSelectorGrid() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children:
          currentHairOptions.map((hair) {
            final selected = hair == _selectedHair;
            return GestureDetector(
              onTap: () {
                _fadeController.reset();
                setState(() {
                  _selectedHair = hair;
                  _isHairBeingEdited = true;
                });
                _fadeController.forward();

                if (_autoAlignHair && _faces.isNotEmpty) {
                  final face = _faces.first;
                  final rect = face.boundingBox;
                  _hairOffset = Offset(rect.left - 20, rect.top - 60);
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
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children:
          glassesList.map((glass) {
            final selected = glass == _selectedGlasses;
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  _selectedGlasses = glass;
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

  Widget _buildSettings() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text("Auto-align Hair"),
          value: _autoAlignHair,
          onChanged: (val) {
            setState(() => _autoAlignHair = val);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text("Reset Hair Position"),
          trailing: const Icon(Icons.refresh),
          onTap: () {
            Navigator.pop(context);
            _resetHairPositionToCenter();
          },
        ),
      ],
    );
  }

  double _angleBetweenVectors(Offset v1, Offset v2) {
    final angle1 = math.atan2(v1.dy, v1.dx);
    final angle2 = math.atan2(v2.dy, v2.dx);
    return angle2 - angle1;
  }

  void _resizeHair(String handle, DragUpdateDetails details) {
    final delta = details.delta;
    const double minSize = 50;
    double boxWidth = 160 * _hairScaleX;
    double boxHeight = 160 * _hairScaleY;
    Offset newOffset = _hairOffset;

    double widthChange = 0;
    double heightChange = 0;

    switch (handle) {
      case 'topLeft':
        widthChange = -delta.dx;
        heightChange = -delta.dy;
        newOffset += Offset(delta.dx, delta.dy);
        break;
      case 'top':
        heightChange = -delta.dy;
        newOffset += Offset(0, delta.dy);
        break;
      case 'topRight':
        widthChange = delta.dx;
        heightChange = -delta.dy;
        newOffset += Offset(0, delta.dy);
        break;
      case 'right':
        widthChange = delta.dx;
        break;
      case 'bottomRight':
        widthChange = delta.dx;
        heightChange = delta.dy;
        break;
      case 'bottom':
        heightChange = delta.dy;
        break;
      case 'bottomLeft':
        widthChange = -delta.dx;
        heightChange = delta.dy;
        newOffset += Offset(delta.dx, 0);
        break;
      case 'left':
        widthChange = -delta.dx;
        newOffset += Offset(delta.dx, 0);
        break;
    }

    double newWidth = boxWidth + widthChange;
    double newHeight = boxHeight + heightChange;

    if (newWidth < minSize) {
      newOffset = Offset(
        newOffset.dx + (newWidth - minSize) * (widthChange < 0 ? 1 : 0),
        newOffset.dy,
      );
      newWidth = minSize;
    }
    if (newHeight < minSize) {
      newOffset = Offset(
        newOffset.dx,
        newOffset.dy + (newHeight - minSize) * (heightChange < 0 ? 1 : 0),
      );
      newHeight = minSize;
    }

    setState(() {
      _hairOffset = newOffset;
      _hairScaleX = newWidth / 160;
      _hairScaleY = newHeight / 160;
    });
  }

  List<Widget> _buildResizeHandles(double boxWidth, double boxHeight) {
    const double handleSize = 20;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureFromCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildGenderToggle(),
          const SizedBox(height: 8),
          _buildImagePreview(),
          const SizedBox(height: 6),
          Text(resultText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        onTap: (index) {
          setState(() => _selectedBottomTab = index);
          if (index == 0) _openPanel("Hair");
          if (index == 1) _openPanel("Glasses");
          if (index == 2) _openPanel("Settings");
        },
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Hairstyle"),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            label: "Glasses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
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
        child:
            _capturedImage == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.teal[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tap the camera icon to take a photo.",
                      style: TextStyle(color: Colors.teal[700], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                : Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double boxWidth = 160 * _hairScaleX;
                        double boxHeight = 160 * _hairScaleY;

                        return RepaintBoundary(
                          key: _imageKey,
                          child: Stack(
                            children: [
                              Image.file(
                                _capturedImage!,
                                width: constraints.maxWidth,
                                fit: BoxFit.contain,
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
                                                        color:
                                                            const Color.fromARGB(
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
                                            ..._buildResizeHandles(
                                              boxWidth,
                                              boxHeight,
                                            ),
                                          if (_isHairBeingEdited)
                                            Positioned(
                                              right: -14,
                                              bottom: -14,
                                              child: Listener(
                                                behavior:
                                                    HitTestBehavior.translucent,
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
                                                        details.position -
                                                        center;
                                                    _initialRotation =
                                                        _hairRotation;
                                                  });
                                                },
                                                onPointerMove: (details) {
                                                  if (!_isRotating ||
                                                      _rotationCenter == null ||
                                                      _rotationStartVector ==
                                                          null) {
                                                    return;
                                                  }

                                                  final currentVector =
                                                      details.position -
                                                      _rotationCenter!;
                                                  final angle =
                                                      _angleBetweenVectors(
                                                        _rotationStartVector!,
                                                        currentVector,
                                                      );

                                                  setState(() {
                                                    _hairRotation =
                                                        _initialRotation +
                                                        angle;
                                                  });
                                                },
                                                onPointerUp: (_) {
                                                  setState(
                                                    () => _isRotating = false,
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
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
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                  1,
                                                                  1,
                                                                ),
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
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap:
                                                    () => setState(
                                                      () =>
                                                          _isHairBeingEdited =
                                                              false,
                                                    ),
                                                child: SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
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
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                  1,
                                                                  1,
                                                                ),
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
