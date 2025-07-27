import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hair_salon/config/api_config.dart';
import 'package:hair_salon/classifiers/glasses_model.dart';
import 'package:hair_salon/screens/try_on_hairstyle.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'try_on_screen.dart';
import 'try_on_glasses.dart';

import '../classifiers/hairstyle_model.dart';
import '/services/image_classifier.dart';

class TryOnScreenPage extends StatefulWidget {
  //added part
  final Hairstyle hairstyle;
  final File capturedImage;
  final bool isMale;

  const TryOnScreenPage({
    super.key,
    // required Hairstyle hairstyle,
    // required File capturedImage,

    //added part
    required this.hairstyle,
    required this.capturedImage,
    required this.isMale,
  });

  @override
  State<TryOnScreenPage> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreenPage>
    with TickerProviderStateMixin {
  List<CameraDescription>? _cameras;
  late final FaceDetector _faceDetector;
  final ImageClassifier _imageClassifier = ImageClassifier();

  List<Face> _faces = [];
  //File? _capturedImage;
  //added part
  late File _capturedImage;
  late Hairstyle _selectedHairstyle;

  //added part
  List<Glasses> _recommendedGlasses = [];

  // Current selected glasses index (or null if none selected)
  int? _selectedGlassesIndex;

  // Position, scale, and rotation for glasses overlay
  Offset _glassesOffset = const Offset(100, 150);
  double _glassesScale = 1.0;
  double _glassesRotation = 0.0;

  //bool _isMale = true;
  late bool _isMale;
  bool _autoAlignHair = true;
  String selectedCategory = "Short";
  int _selectedBottomTab = 0;
  String resultText = "Tap the camera icon to take a photo.";
  String _selectedHair = '';

  Offset _hairOffset = const Offset(100, 150);
  double _hairScale = 1.0;
  double _hairRotation = 0.0;

  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  final GlobalKey _imageKey = GlobalKey();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Map<String, List<Hairstyle>> maleHairs = {
    "Short": [],
    "Medium": [],
    "Long": [],
  };

  final Map<String, List<Hairstyle>> femaleHairs = {
    "Short": [],
    "Medium": [],
    "Long": [],
  };

  List<Hairstyle> get currentHairOptions =>
      _isMale
          ? maleHairs[selectedCategory] ?? []
          : femaleHairs[selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _isMale = widget.isMale;
    _initCamera();
    _imageClassifier.init();

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

    //added part
    // Use passed image and hairstyle
    _capturedImage = widget.capturedImage;
    _selectedHairstyle = widget.hairstyle;
    _selectedHair = _selectedHairstyle.imageUrl;

    _detectFacesAndAlignHair(); // face detection and overlay
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
  }

  //added part
  Future<void> _detectFacesAndAlignHair() async {
    final inputImage = InputImage.fromFile(_capturedImage);
    final faces = await _faceDetector.processImage(inputImage);

    setState(() => _faces = faces);

    if (_autoAlignHair && faces.isNotEmpty) {
      final face = faces.first;
      final rect = face.boundingBox;
      setState(() {
        _hairOffset = Offset(rect.left + rect.width / 2 - 60, rect.top - 80);
        _hairScale = rect.width / 150;
        _hairRotation = 0.0;
      });
    }

    final result = await _imageClassifier.classifyImage(_capturedImage);
    if (result.containsKey('error')) {
      setState(() => resultText = "Error: ${result['error']}");
    } else {
      final fullLabel = result['label'];
      final faceShape =
          RegExp(r'^\s*([A-Za-z]+)').firstMatch(fullLabel)?.group(1) ??
          fullLabel;
      final gender = _isMale ? 'Male' : 'Female';

      setState(() {
        resultText =
            "Detected face shape: $faceShape (Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%)";
      });

      await getRecommendedHairstyles(faceShape, gender);
      await getRecommendedGlasses(faceShape, gender);
    }
  }

  //added part
  Future<void> getRecommendedHairstyles(String faceShape, String gender) async {
    final uri = ApiConfig.getRecommendHairstylesUri(faceShape, gender);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final allHairstyles =
            jsonData.map((item) => Hairstyle.fromJson(item)).toList();

        final short = <Hairstyle>[];
        final medium = <Hairstyle>[];
        final long = <Hairstyle>[];

        for (var style in allHairstyles) {
          switch (style.category) {
            case 'Short':
              short.add(style);
              break;
            case 'Medium':
              medium.add(style);
              break;
            case 'Long':
              long.add(style);
              break;
          }
        }

        setState(() {
          if (gender == 'Male') {
            maleHairs['Short'] = short;
            maleHairs['Medium'] = medium;
            maleHairs['Long'] = long;
          } else {
            femaleHairs['Short'] = short;
            femaleHairs['Medium'] = medium;
            femaleHairs['Long'] = long;
          }
        });
      }
    } catch (e) {
      print("Error fetching hairstyles: $e");
    }
  }

  Future<void> getRecommendedGlasses(String faceShape, String gender) async {
    final uri = ApiConfig.getRecommendGlassesUri(faceShape, gender);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final glassesList =
            jsonData.map((item) => Glasses.fromJson(item)).toList();

        setState(() => _recommendedGlasses = glassesList);
      }
    } catch (e) {
      print("Error fetching glasses: $e");
    }
  }

  void _resetHairPositionToCenter() {
    final context = _imageKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final size = box.size;
      setState(() {
        _hairOffset = Offset(size.width / 2 - 60, size.height / 2 - 60);
        _hairScale = 1.0;
        _hairRotation = 0.0;
      });
    }
  }

  //added part
  void _resetGlassesPositionToCenter() {
    final context = _imageKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final size = box.size;
      setState(() {
        _glassesOffset = Offset(size.width / 2 - 80, size.height / 2 - 40);
        _glassesScale = 1.0;
        _glassesRotation = 0.0;
      });
    }
  }

  Future<void> incrementHairstylePopularity(String hairstyleId) async {
    // const baseUrl = 'https://your-api-domain.com'; //  Replace with your backend
    final url = ApiConfig.getIncrementPopularityUri(hairstyleId);

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('Popularity incremented for $hairstyleId');
      } else {
        print(' Failed to increment popularity: ${response.body}');
      }
    } catch (e) {
      print(' Error incrementing popularity: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _faceDetector.close();
    _imageClassifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Hairstyle Try-On"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.camera_alt),
        //     onPressed: _captureFromCamera,
        //   ),
        // ],
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
              //added part
              _recommendedGlasses = [];
              _selectedGlassesIndex = null;
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
                ? const Text("Tap the camera icon to take a photo.")
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SizedBox(
                          key: _imageKey,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Image.file(
                            _capturedImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                        //overlay hairstyle
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
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        _selectedHair.startsWith('http')
                                            ? Image.network(
                                              _selectedHair,
                                              fit: BoxFit.contain,
                                            )
                                            : Image.asset(
                                              _selectedHair,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Overlay glasses
                        if (_faces.isNotEmpty && _selectedGlassesIndex != null)
                          Positioned(
                            left: _glassesOffset.dx,
                            top: _glassesOffset.dy,
                            child: GestureDetector(
                              onScaleStart: (details) {
                                _initialFocalPoint = details.focalPoint;
                                _initialOffset = _glassesOffset;
                                _initialScale = _glassesScale;
                                _initialRotation = _glassesRotation;
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  final delta =
                                      details.focalPoint - _initialFocalPoint;
                                  _glassesOffset = _initialOffset + delta;
                                  _glassesScale = (_initialScale *
                                          details.scale)
                                      .clamp(0.5, 3.0);
                                  _glassesRotation =
                                      _initialRotation + details.rotation;
                                });
                              },
                              child: Transform(
                                alignment: Alignment.center,
                                transform:
                                    Matrix4.identity()
                                      ..translate(80.0, 40.0)
                                      ..rotateZ(_glassesRotation)
                                      ..scale(_glassesScale)
                                      ..translate(-80.0, -40.0),
                                child: SizedBox(
                                  width: 160,
                                  height: 80,
                                  child: Image.network(
                                    "${ApiConfig.baseUrl}/public/images/glasses/${_recommendedGlasses[_selectedGlassesIndex!].imageUrl}",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
      ),
    );
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
              builder:
                  (_, controller) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child:
                        type == "Hair"
                            ? Column(
                              children: [
                                _buildCategoryTabs(setModalState),
                                const SizedBox(height: 10),
                                Expanded(child: _buildHairSelectorGrid()),
                              ],
                            )
                            //added part
                            : type == "Glasses"
                            ? _buildGlassesSelectorGrid()
                            : _buildSettings(),
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryTabs(void Function(void Function()) setModalState) {
    final Map<String, List<Hairstyle>> hairMap =
        _isMale ? maleHairs : femaleHairs;

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
          currentHairOptions.map((hairstyle) {
            final selected = hairstyle.imageUrl == _selectedHair;
            return GestureDetector(
              onTap: () async {
                _fadeController.reset();
                setState(() => _selectedHair = hairstyle.imageUrl);
                _fadeController.forward();

                if (_autoAlignHair && _faces.isNotEmpty) {
                  final face = _faces.first;
                  final rect = face.boundingBox;

                  setState(() {
                    _hairOffset = Offset(
                      rect.left +
                          rect.width / 2 -
                          60, // center hair horizontally on face
                      rect.top - 80, // place hair slightly above top of face
                    );
                    _hairScale =
                        rect.width / 150; // scale hair size to match face width
                    _hairRotation = 0.0; // can be enhanced later
                  });
                } else {
                  _resetHairPositionToCenter();
                }

                // for popularity counting
                await incrementHairstylePopularity(hairstyle.hairstyleId);

                // Navigate to TryOnScreenPage passing hairstyle and captured image
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TryOnHairstyles(
                          hairstyle: hairstyle,
                          capturedImage: _capturedImage,
                          //added part
                          isMale: _isMale,
                        ),
                  ),
                );
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
                child: Image.network(hairstyle.imageUrl, fit: BoxFit.contain),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildGlassesSelectorGrid() {
    if (_recommendedGlasses.isEmpty) {
      return const Center(child: Text("No glasses recommendations available."));
    }

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children:
          _recommendedGlasses.map((glass) {
            final selected =
                _recommendedGlasses.indexOf(glass) == _selectedGlassesIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGlassesIndex = _recommendedGlasses.indexOf(glass);
                  _resetGlassesPositionToCenter();
                });
                // Navigator.pop(context); // Optional: close panel on selection
                // Optional: navigate to TryOnGlassesScreen like hairstyles
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TryOnGlassesScreen(
                          capturedImage: _capturedImage,
                          //isMale: _isMale,
                          glassesImageUrl:
                              "${ApiConfig.baseUrl}/public/glasses/${glass.imageUrl}",
                        ),
                  ),
                );
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
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        "${ApiConfig.baseUrl}/public/glasses/${glass.imageUrl}",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      glass.glassesName,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.teal : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
}
