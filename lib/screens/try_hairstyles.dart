import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
// import 'hairstyle_editor_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
  late File _capturedImage;
  File? _processedImage;

  // Backend integration state
  String selectedFaceShape = "All";
  String selectedGender = "Male";
  bool isLoadingHairs = false;
  Map<String, List<dynamic>> maleHairs = {
    "All": [],
    "Oval": [],
    "Round": [],
    "Square": [],
    "Heart": [],
    "Oblong": [],
  };
  Map<String, List<dynamic>> femaleHairs = {
    "All": [],
    "Oval": [],
    "Round": [],
    "Square": [],
    "Heart": [],
    "Oblong": [],
  };
  List<String> faceShapeTabs = [
    "All",
    "Oval",
    "Round",
    "Square",
    "Heart",
    "Oblong",
  ];

  String _selectedHair = '';
  final bool _isMale = true;
  bool _isProcessing = false;
  String resultText = "Adjust your hairstyle";
  int _selectedBottomTab = 0;
  bool _isHairBeingEdited = false;
  bool _isRotating = false;
  Offset _hairOffset = const Offset(100, 150);
  double _hairScaleX = 1.0;
  double _hairScaleY = 1.0;
  double _hairRotation = 0.0;
  Offset? _rotationStartVector;
  double _initialRotation = 0;
  Offset? _rotationCenter;
  final double _initialScale = 1.0;
  final Offset _initialOffset = Offset.zero;
  final GlobalKey _imageKey = GlobalKey();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Glasses state
  List<dynamic> _recommendedGlasses = [];
  int? _selectedGlassesIndex;
  String _selectedGlassesFaceShape = "All";
  bool _isLoadingGlasses = false;
  Offset _glassesOffset = const Offset(100, 150);
  double _glassesScale = 1.0;
  double _glassesRotation = 0.0;
  Offset _glassesInitialOffset = Offset.zero;
  double _glassesInitialScale = 1.0;
  double _glassesInitialRotation = 0.0;
  Offset _glassesInitialFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _capturedImage = widget.initialImage;
    _initializeImageProcessing();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    // Default gender and face shape
    selectedGender = _isMale ? "Male" : "Female";
    selectedFaceShape = "All";
    getRecommendedHairstyles(selectedFaceShape, selectedGender);
    _selectedGlassesFaceShape = "All";
    getRecommendedGlasses(_selectedGlassesFaceShape, selectedGender);
  }

  Future<File> _fixImageOrientation(File file) async {
    try {
      final byteData = await file.readAsBytes();
      Uint8List bytes = byteData.buffer.asUint8List();

      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) return file;

      originalImage = img.copyRotate(originalImage, angle: 0);

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

  Future<void> _initializeImageProcessing() async {
    if (mounted) {
      setState(() {
        _isProcessing = true;
        resultText = "Processing image...";
      });
    }

    try {
      _processedImage = await _fixImageOrientation(_capturedImage);

      setState(() {
        resultText = "Adjust your hairstyle.";
        _resetHairPositionToCenter();
        if (_selectedHair.isEmpty && currentHairOptions.isNotEmpty) {
          _selectedHair = currentHairOptions.first['imageUrl'];
          _isHairBeingEdited = true;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => resultText = "Error processing image: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> getRecommendedHairstyles(String faceShape, String gender) async {
    setState(() {
      isLoadingHairs = true;
    });
    try {
      final uri = ApiConfig.getRecommendHairstylesUri(
        faceShape.toLowerCase(),
        gender.toLowerCase(),
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        Map<String, List<dynamic>> groupedHairs = {
          "All": [],
          "Oval": [],
          "Round": [],
          "Square": [],
          "Heart": [],
          "Oblong": [],
        };
        for (var h in data) {
          final faceShapes = List<String>.from(h['faceShapes'] ?? []);
          for (var shape in faceShapes) {
            final key = shape[0].toUpperCase() + shape.substring(1).toLowerCase();
            if (groupedHairs.containsKey(key)) {
              groupedHairs[key]!.add(h);
            }
          }
          groupedHairs["All"]!.add(h);
        }
        setState(() {
          if (gender.toLowerCase() == 'male') {
            maleHairs = groupedHairs;
          } else {
            femaleHairs = groupedHairs;
          }
          isLoadingHairs = false;
        });
      } else {
        setState(() {
          isLoadingHairs = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingHairs = false;
      });
    }
  }

  Future<void> getRecommendedGlasses(String faceShape, String gender) async {
    setState(() {
      _isLoadingGlasses = true;
    });
    final uri = ApiConfig.getRecommendGlassesUri(
      faceShape.toLowerCase(),
      gender.toLowerCase(),
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _recommendedGlasses = jsonData;
          _isLoadingGlasses = false;
          _selectedGlassesIndex = null;
        });
      } else {
        setState(() {
          _isLoadingGlasses = false;
          _recommendedGlasses = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingGlasses = false;
        _recommendedGlasses = [];
      });
    }
  }

  List<dynamic> get currentHairOptions {
    final map = _isMale ? maleHairs : femaleHairs;
    return map[selectedFaceShape] ?? [];
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

  void _resetGlassesPositionToCenter() {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final size = box.size;
      setState(() {
        _glassesOffset = Offset(size.width / 2 - 80, size.height / 2 - 40);
        _glassesScale = 1.0;
        _glassesRotation = 0.0;
      });
    }
  }

  Future<void> _saveImage() async {
    try {
      if (_selectedHair.isEmpty) return;

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
                  child: Column(
                    children: [
                      _buildCategoryTabs(setModalState),
                      const SizedBox(height: 10),
                      Expanded(child: _buildHairSelectorGrid()),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryTabs(void Function(void Function()) setModalState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: faceShapeTabs.map((category) {
          final selected = selectedFaceShape == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (isSelected) {
                setModalState(() {
                  selectedFaceShape = category;
                  _selectedHair = '';
                });
                setState(() {});
                getRecommendedHairstyles(selectedFaceShape, selectedGender);
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
    if (isLoadingHairs) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: currentHairOptions.map((hair) {
        final imageUrl = "${ApiConfig.baseUrl}/public/hairstyles/${hair['imageUrl']}";
        final selected = imageUrl == _selectedHair;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _fadeController.reset();
            setState(() {
              _selectedHair = imageUrl;
              _isHairBeingEdited = true;
            });
            _fadeController.forward();
            _resetHairPositionToCenter();
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
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlassesGrid() {
    if (_isLoadingGlasses) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredGlasses = _selectedGlassesFaceShape == "All"
        ? _recommendedGlasses
        : _recommendedGlasses.where((g) => (g['faceShapes'] ?? []).contains(_selectedGlassesFaceShape)).toList();
    if (filteredGlasses.isEmpty) {
      return const Center(child: Text("No glasses recommendations available."));
    }
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: List.generate(filteredGlasses.length, (index) {
        final glass = filteredGlasses[index];
        final imageUrl = "${ApiConfig.baseUrl}/public/glasses/${glass['imageUrl']}";
        final selected = _selectedGlassesIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGlassesIndex = index;
              _resetGlassesPositionToCenter();
            });
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
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        );
      }),
    );
  }

  Widget _buildGlassesTabs(void Function(void Function()) setModalState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: faceShapeTabs.map((category) {
          final selected = _selectedGlassesFaceShape == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (isSelected) {
                setModalState(() {
                  _selectedGlassesFaceShape = category;
                  _selectedGlassesIndex = null;
                });
                setState(() {});
                getRecommendedGlasses(_selectedGlassesFaceShape, selectedGender);
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

    newWidth = newWidth.clamp(minSize, maxSize);
    newHeight = newHeight.clamp(minSize, maxSize);

    if (newWidth == minSize || newWidth == maxSize) {
      newOffset = Offset(
        _initialOffset.dx + (boxWidth - newWidth) * (widthChange < 0 ? 1 : 0),
        newOffset.dy,
      );
    }
    if (newHeight == minSize || newHeight == maxSize) {
      newOffset = Offset(
        newOffset.dx,
        _initialOffset.dy +
            (boxHeight - newHeight) * (heightChange < 0 ? 1 : 0),
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
                  // const SizedBox(height: 8),
                  // _buildGenderToggle(),
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
        onTap: (index) async {
          setState(() => _selectedBottomTab = index);

          if (index == 0) {
            _openPanel("Hair");
          } else if (index == 1) {
            _openPanel("Glasses");
          } else if (index == 2) {
            final File imageToEdit = _processedImage ?? _capturedImage;

            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (_) => HairstyleEditorScreen(
            //       baseImage: imageToEdit,
            //       hairAssetPath: _selectedHair,
            //       isMale: _isMale,
            //     ),
            //   ),
            // );

            // if (result != null && result is Uint8List) {
            //   final tempDir = await getTemporaryDirectory();
            //   final tempPath =
            //       '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
            //   final editedFile = File(tempPath);
            //   await editedFile.writeAsBytes(result);

            //   setState(() {
            //     _processedImage = editedFile;
            //     _resetHairPositionToCenter();
            //   });

            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Edited image saved')),
            //   );
            // }
            //
          }
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

  // Widget _buildGenderToggle() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       ToggleButtons(
  //         isSelected: [_isMale, !_isMale],
  //         onPressed: (index) {
  //           setState(() {
  //             _isMale = index == 0;
  //             selectedCategory = "Short";
  //             _selectedHair = '';
  //           });
  //         },
  //         borderRadius: BorderRadius.circular(25),
  //         selectedColor: Colors.white,
  //         fillColor: Colors.teal,
  //         constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
  //         children: const [
  //           Text("Male", style: TextStyle(fontSize: 16)),
  //           Text("Female", style: TextStyle(fontSize: 16)),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildImagePreview() {
    return Expanded(
      child: Center(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double boxWidth = 160 * _hairScaleX;
                double boxHeight = 160 * _hairScaleY;
                double glassesWidth = 160;
                double glassesHeight = 80;
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
                            key: ValueKey(_processedImage?.path ?? _capturedImage.path),
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
                                    decoration: _isHairBeingEdited
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(255, 59, 193, 255),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                    child: ClipRect(
                                      child: _selectedHair.startsWith('http')
                                          ? Image.network(
                                              _selectedHair,
                                              fit: BoxFit.cover,
                                              width: boxWidth,
                                              height: boxHeight,
                                            )
                                          : Image.asset(
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
                                          final renderBox = context.findRenderObject() as RenderBox;
                                          final center = renderBox.localToGlobal(
                                            Offset(boxWidth / 2, boxHeight / 2),
                                          );
                                          setState(() {
                                            _isRotating = true;
                                            _rotationCenter = center;
                                            _rotationStartVector = details.position - center;
                                            _initialRotation = _hairRotation;
                                          });
                                        },
                                        onPointerMove: (details) {
                                          if (!_isRotating || _rotationCenter == null || _rotationStartVector == null) {
                                            return;
                                          }

                                          final currentVector = details.position - _rotationCenter!;
                                          final angle = _angleBetweenVectors(_rotationStartVector!, currentVector);

                                          setState(() {
                                            _hairRotation = _initialRotation + angle;
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
                                                    color: Colors.black.withOpacity(0.2),
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
                                        onTap: () => setState(() => _isHairBeingEdited = false),
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
                                                    color: Colors.black.withOpacity(0.2),
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
                      if (_selectedGlassesIndex != null && _selectedGlassesIndex! < _recommendedGlasses.length)
                        Positioned(
                          left: _glassesOffset.dx,
                          top: _glassesOffset.dy,
                          child: GestureDetector(
                            onScaleStart: (d) {
                              _glassesInitialFocalPoint = d.focalPoint;
                              _glassesInitialOffset = _glassesOffset;
                              _glassesInitialScale = _glassesScale;
                              _glassesInitialRotation = _glassesRotation;
                            },
                            onScaleUpdate: (d) {
                              setState(() {
                                final delta = d.focalPoint - _glassesInitialFocalPoint;
                                _glassesOffset = _glassesInitialOffset + delta;
                                _glassesScale = (_glassesInitialScale * d.scale).clamp(0.5, 3.0);
                                _glassesRotation = _glassesInitialRotation + d.rotation;
                              });
                            },
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..translate(glassesWidth / 2, glassesHeight / 2)
                                ..rotateZ(_glassesRotation)
                                ..scale(_glassesScale)
                                ..translate(-glassesWidth / 2, -glassesHeight / 2),
                              child: Image.network(
                                "${ApiConfig.baseUrl}/public/glasses/${_recommendedGlasses[_selectedGlassesIndex!]['imageUrl']}",
                                width: glassesWidth,
                                height: glassesHeight,
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
