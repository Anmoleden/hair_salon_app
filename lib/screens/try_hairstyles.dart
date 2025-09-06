import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'take_photo_page.dart';
import '../screens/hairstyle_details_screen.dart';
import '../classifiers/hairstyle_model.dart';

class TryHairstyles extends StatefulWidget {
  final File? croppedImage;
  const TryHairstyles({super.key, this.croppedImage});

  @override
  State<TryHairstyles> createState() => _TryHairstylesState();
}

class _TryHairstylesState extends State<TryHairstyles>
    with TickerProviderStateMixin {
  // ... (existing variables remain the same)

  // New state variables for expandable tabs
  bool _tabsExpanded = false;
  double _tabsHeight = 60.0;
  final double _expandedHeight = 200.0;

  // Add missing variable definitions
  final GlobalKey _imageKey = GlobalKey();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedHair = '';
  bool _autoAlignHair = true;
  List<Face> _faces = [];
  Offset _hairOffset = const Offset(100, 150);
  double _hairScale = 1.0;
  double _hairRotation = 0.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;
  Size? _imageSize;
  Size? _hairImageSize;
  File? _capturedImage;
  String resultText = "Tap the camera icon to take a photo.";
  String _selectedGlasses = '';
  String selectedCategory = "Short";
  bool tabsAboveImage = false;
  bool _isMale = true;
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
  late final FaceDetector _faceDetector;
  List<String> get currentHairOptions =>
      _isMale
          ? maleHairs[selectedCategory] ?? []
          : femaleHairs[selectedCategory] ?? [];
  final List<String> glassesList = [
    'assets/glasses/glass1.png',
    'assets/glasses/glass2.png',
  ];

  @override
  void initState() {
    super.initState();
    // ... (existing initState remains the same)
  }

  // ... (existing methods remain the same until build method)

  void _toggleTabs() {
    setState(() {
      _tabsExpanded = !_tabsExpanded;
      _tabsHeight = _tabsExpanded ? _expandedHeight : 60.0;
    });
  }

  void _handleHairSelection(String hair) {
    setState(() {
      _fadeController.reset();
      _selectedHair = hair;
      _fadeController.forward();

      if (_autoAlignHair && _faces.isNotEmpty) {
        final face = _faces.first;
        final rect = face.boundingBox;
        _hairOffset = Offset(rect.left - 20, rect.top - 60);
        _hairScale = 1.0;
        _hairRotation = 0.0;
      } else {
        _resetHairPositionToCenter();
      }

      // Collapse tabs after selection
      _tabsExpanded = false;
      _tabsHeight = 60.0;
    });
  }

  void _resetHairPositionToCenter() {
    setState(() {
      _hairOffset = const Offset(100, 150);
      _hairScale = 1.0;
      _hairRotation = 0.0;
    });
  }

  Future<void> _captureFromCamera() async {
    // ... your camera capture logic ...
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
      body: Stack(
        children: [
          // Fullscreen image with overlay
          if (_capturedImage != null || widget.croppedImage != null)
            Positioned.fill(
              child: Image.file(
                _capturedImage ?? widget.croppedImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            Positioned.fill(child: _buildImagePreview()),

          // Overlay: hair/glasses on image
          if (_selectedHair.isNotEmpty &&
              (_capturedImage != null || widget.croppedImage != null))
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _initialFocalPoint = details.focalPoint;
                  _initialOffset = _hairOffset;
                  _initialScale = _hairScale;
                  _initialRotation = _hairRotation;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    final delta = details.focalPoint - _initialFocalPoint;
                    _hairOffset = _initialOffset + delta;
                    _hairScale = (_initialScale * details.scale).clamp(
                      0.5,
                      3.0,
                    );
                    _hairRotation = _initialRotation + details.rotation;
                  });
                },
                child: Stack(
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..translate(_hairOffset.dx, _hairOffset.dy)
                            ..translate(60.0, 60.0)
                            ..rotateZ(_hairRotation)
                            ..scale(_hairScale)
                            ..translate(-60.0, -60.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Image.asset(
                            _selectedHair,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedGlasses.isNotEmpty)
                      Positioned(
                        top: _hairOffset.dy + 80,
                        left: _hairOffset.dx + 20,
                        child: Image.asset(
                          _selectedGlasses,
                          width: 100,
                          height: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // DraggableScrollableSheet for tabs and hair selector
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.12,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    _buildGenderCategoryTabs(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: _buildHairSelectorGrid(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay: result text at bottom (above tabs)
          Positioned(
            left: 0,
            right: 0,
            bottom:
                MediaQuery.of(context).size.height * 0.18 +
                20, // Position above draggable sheet
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  resultText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildGenderCategoryTabs() {
    final List<String> tabs = ['Female', 'Short', 'Medium', 'Male', 'Long'];
    int selectedIndex = 0;
    if (_isMale) selectedIndex = 3;
    if (selectedCategory == 'Short') selectedIndex = _isMale ? 3 : 1;
    if (selectedCategory == 'Medium') selectedIndex = _isMale ? 3 : 2;
    if (selectedCategory == 'Long') selectedIndex = 4;
    return Container(
      height: 48,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          bool selected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                tabsAboveImage = !tabsAboveImage;
                if (tabs[index] == 'Female') {
                  _isMale = false;
                  selectedCategory = 'Short';
                  _selectedHair = '';
                } else if (tabs[index] == 'Male') {
                  _isMale = true;
                  selectedCategory = 'Short';
                  _selectedHair = '';
                } else if (tabs[index] == 'Short') {
                  selectedCategory = 'Short';
                  _selectedHair = '';
                } else if (tabs[index] == 'Medium') {
                  selectedCategory = 'Medium';
                  _selectedHair = '';
                } else if (tabs[index] == 'Long') {
                  selectedCategory = 'Long';
                  _selectedHair = '';
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.teal : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
              onTap: () => _handleHairSelection(hair),
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

  // Widget _buildSettings() {
  //   return ListView(
  //     children: [
  //       SwitchListTile(
  //         title: const Text("Auto-align Hair"),
  //         value: _autoAlignHair,
  //         onChanged: (val) {
  //           setState(() => _autoAlignHair = val);
  //           Navigator.pop(context);
  //         },
  //       ),
  //       ListTile(
  //         title: const Text("Reset Hair Position"),
  //         trailing: const Icon(Icons.refresh),
  //         onTap: () {
  //           Navigator.pop(context);
  //           _resetHairPositionToCenter();
  //         },
  //       ),
  //     ],
  //   );
  // }

  @override
  void dispose() {
    _fadeController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Widget _buildImagePreview() {
    final File? imageToShow = _capturedImage ?? widget.croppedImage;
    return Expanded(
      child: Center(
        child:
            imageToShow == null
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
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    return Stack(
                      children: [
                        Container(
                          key: _imageKey,
                          width: maxWidth,
                          height: maxHeight,
                          child: Image.file(imageToShow, fit: BoxFit.contain),
                        ),
                        if (_faces.isNotEmpty && _selectedHair.isNotEmpty)
                          Positioned(
                            left: _hairOffset.dx,
                            top: _hairOffset.dy,
                            child: GestureDetector(
                              onScaleStart: (details) {
                                _initialFocalPoint = details.focalPoint;
                                _initialOffset = _hairOffset;
                                _initialScale = _hairScale;
                                _initialRotation = _hairRotation;
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  if (!_autoAlignHair) {
                                    final delta =
                                        details.focalPoint - _initialFocalPoint;
                                    _hairOffset = _initialOffset + delta;
                                  }
                                  _hairScale = (_initialScale * details.scale)
                                      .clamp(0.5, 3.0);
                                  _hairRotation =
                                      _initialRotation + details.rotation;
                                });
                              },
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform:
                                      Matrix4.identity()
                                        ..translate(60.0, 60.0)
                                        ..rotateZ(_hairRotation)
                                        ..scale(_hairScale)
                                        ..translate(-60.0, -60.0),
                                  child: SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Image.asset(
                                      _selectedHair,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_selectedGlasses.isNotEmpty)
                          Positioned(
                            top: _hairOffset.dy + 80,
                            left: _hairOffset.dx + 20,
                            child: Image.asset(
                              _selectedGlasses,
                              width: 100,
                              height: 40,
                            ),
                          ),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
