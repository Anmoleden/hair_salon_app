// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// import '../classifiers/glasses_model.dart';
// import '../classifiers/hairstyle_model.dart';
// import '../config/api_config.dart';
// import 'try_on_glasses.dart';
// import 'try_on_screen_original.dart';

// class TryHairstylesDirect extends StatefulWidget {
//   final bool isMale;
//   final Hairstyle? hairstyle;
//   final String faceShape = "All";
//   final String gender;
//   //added part
//   final File? initialImage;
//   final bool isFromCamera;

//   const TryHairstylesDirect({
//     super.key,
//     this.hairstyle,
//     this.isMale = true,
//     required this.gender,
//    //required this.faceShape,

//     this.initialImage,
//     this.isFromCamera = false, required String faceShape,
//   });

//   @override
//   State<TryHairstylesDirect> createState() => _TryHairstylesDirectState();
// }

// class _TryHairstylesDirectState extends State<TryHairstylesDirect>
//     with TickerProviderStateMixin {
//   final bool _isMale = true;
//   final bool _autoAlignHair = true;
//   String selectedCategory = "";
//   int _selectedBottomTab = 0;
//   String resultText = "";

//   Offset _hairOffset = const Offset(100, 150);
//   double _hairScaleX = 1.0;
//   double _hairScaleY = 1.0;
//   double _hairRotation = 0.0;
//   bool _isHairBeingEdited = false;
//   final bool _isRotating = false;

//   final GlobalKey _imageKey = GlobalKey();
//   String _selectedHair = '';
//   final String _selectedGlasses = '';

//   String _selectedFaceShape = '';
//   String _selectedGender = '';

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   Offset? _rotationStartVector;
//   double _initialRotation = 0;
//   Offset? _rotationCenter;
//   double _initialScale = 1.0;
//   Offset _initialOffset = Offset.zero;

//   double _hairScale = 1.0;

//   List<Glasses> _recommendedGlasses = [];
//   int? _selectedGlassesIndex;

//   List<Hairstyle> recommendedHairstyles = [];

//   //added part+
//   final List<String> faceShapeTabs = [
//     "All",
//     "Oval",
//     "Round",
//     "Square",
//     "Heart",
//     "Oblong",
//   ];
//   String _selectedGlassesFaceShape = ""; // Initialized in initState
//   bool _isLoadingGlasses = false;

//   bool _isLoadingHairs = false; // For loading indicator during fetch

//   Offset _initialFocalPoint = Offset.zero;

//   Offset _glassesOffset = const Offset(100, 150);
//   double _glassesScale = 1.0;
//   double _glassesRotation = 0.0;

//   final Map<String, List<Hairstyle>> maleHairs = {
//     "All": [],
//     "Oval": [],
//     "Round": [],
//     "Square": [],
//     "Heart": [],
//     "Oblong": [],
//   };

//   final Map<String, List<Hairstyle>> femaleHairs = {
//     "All": [],
//     "Oval": [],
//     "Round": [],
//     "Square": [],
//     "Heart": [],
//     "Oblong": [],
//   };

//   List<Hairstyle> get currentHairOptions {
//     final isMale = _selectedGender.toLowerCase() == 'male';
//     final map = isMale ? maleHairs : femaleHairs;
//     final hairs = map[_selectedFaceShape];
//     print(
//       "Getter currentHairOptions: faceShape=$_selectedFaceShape, hairs count=${hairs?.length ?? 0}",
//     );
//     return hairs ?? [];
//   }

//   Widget _buildFaceShapeTabs(void Function(void Function()) setModalState) {
//     final faceShapes = ['All', 'Oval', 'Round', 'Square', 'Heart', 'Oblong'];

//     return SizedBox(
//       height: 40,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: faceShapes.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, index) {
//           final shape = faceShapes[index];
//           final isSelected = _selectedFaceShape == shape;

//           return GestureDetector(
//             onTap: () {
//               setModalState(() {
//                 _selectedFaceShape = shape;
//                 getRecommendedGlasses(_selectedFaceShape, _selectedGender);
//                 getRecommendedHairstyles(_selectedFaceShape, _selectedGender);
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.black : Colors.grey[300],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 shape,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     //added part
//     _selectedFaceShape =
//         widget.faceShape.isNotEmpty
//             ? widget.faceShape[0].toUpperCase() +
//                 widget.faceShape.substring(1).toLowerCase()
//             : faceShapeTabs[0];

//     _selectedGender = widget.gender;

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
//     resultText = "Detected face shape: ${widget.faceShape}";

//     // Fetch recommendations immediately after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await getRecommendedHairstyles(widget.faceShape, widget.gender);
//       await getRecommendedGlasses(widget.faceShape, widget.gender);
//     });
//   }

//   Future<void> getRecommendedHairstyles(String faceShape, String gender) async {
//     setState(() {
//       _isLoadingHairs = true;
//     });

//     try {
//       final uri = ApiConfig.getRecommendHairstylesUri(
//         faceShape.toLowerCase(), // backend expects lowercase in query
//         gender.toLowerCase(),
//       );

//       print("Fetching hairstyles from: $uri");

//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         final allHairstyles =
//             data.map((json) => Hairstyle.fromJson(json)).toList();

//         Map<String, List<Hairstyle>> groupedHairs = {};

//         // Group hairstyles by capitalized faceShape string (exact keys)
//         for (var h in allHairstyles) {
//           for (var shape in h.faceShapes) {
//             final trimmedShape = shape.trim();
//             if (trimmedShape.isEmpty) continue;

//             // Make sure key is capitalized like in DB
//             final key =
//                 trimmedShape[0].toUpperCase() +
//                 trimmedShape.substring(1).toLowerCase();

//             if (!groupedHairs.containsKey(key)) {
//               groupedHairs[key] = [];
//             }
//             groupedHairs[key]!.add(h);
//           }
//         }
//         setState(() {
//           if (gender.toLowerCase() == 'male') {
//             maleHairs.clear();
//             maleHairs.addAll(groupedHairs);
//             maleHairs['All'] = allHairstyles; // ✅ Add All tab for males
//           } else {
//             femaleHairs.clear();
//             femaleHairs.addAll(groupedHairs);
//             femaleHairs['All'] = allHairstyles; // ✅ Add All tab for females
//           }

//           _isLoadingHairs = false;

//           // Debug prints
//           print("Grouped hairs keys: ${groupedHairs.keys}");
//           print("maleHairs keys: ${maleHairs.keys}");
//           print("femaleHairs keys: ${femaleHairs.keys}");
//           print("Current selected face shape: $_selectedFaceShape");
//           print(
//             "Hairstyles count for $_selectedFaceShape: ${currentHairOptions.length}",
//           );
//         });
//       } else {
//         print("Failed to load hairstyles. Status code: ${response.statusCode}");
//         setState(() {
//           _isLoadingHairs = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching recommended hairstyles: $e");
//       setState(() {
//         _isLoadingHairs = false;
//       });
//     }
//   }

//   Future<void> getRecommendedGlasses(String faceShape, String gender) async {
//     //added part
//     setState(() {
//       _isLoadingGlasses = true;
//     });

//     final uri = ApiConfig.getRecommendGlassesUri(
//       faceShape.toLowerCase(),
//       gender.toLowerCase(),
//     );

//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = jsonDecode(response.body);
//         final List<Glasses> glassesList =
//             jsonData.map((e) => Glasses.fromJson(e)).toList();
//         //setState(() => _recommendedGlasses = glassesList);
//         //added part
//         // ✅ Add 'All' to each glasses item BEFORE setting state
//         for (var g in glassesList) {
//           if (!g.faceShapes.contains('All')) {
//             g.faceShapes.add('All');
//           }
//         }
//         setState(() {
//           _recommendedGlasses = glassesList;
//           _isLoadingGlasses = false;
//           _selectedGlassesIndex = null; // reset selection on new load
//           // Add the All tab manually (group by face shape if needed later)
//           // if (!_recommendedGlasses.any((g) => g.faceShapes.contains('All'))) {
//           //   for (var g in glassesList) {
//           //     g.faceShapes.add('All');
//           //   }
//           // }
//         });
//       } else {
//         print("Failed to load glasses. Status code: ${response.statusCode}");
//         //added part
//         setState(() {
//           _isLoadingGlasses = false;
//           _recommendedGlasses = [];
//         });
//       }
//     } catch (e) {
//       print("Error getting glasses: $e");
//       //added part
//       setState(() {
//         _isLoadingGlasses = false;
//         _recommendedGlasses = [];
//       });
//     }
//   }

//   void _resetHairPositionToCenter() {
//     final context = _imageKey.currentContext;
//     if (context != null) {
//       final box = context.findRenderObject() as RenderBox?;
//       if (box != null) {
//         final size = box.size;
//         setState(() {
//           _hairOffset = Offset(size.width / 2 - 60, size.height / 2 - 60);
//           _hairScaleX = 1.0;
//           _hairScaleY = 1.0;
//           _hairRotation = 0.0;
//           _isHairBeingEdited = true;
//         });
//       }
//     }
//   }

//   void _resetGlassesPositionToCenter() {
//     final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final size = box.size;
//       setState(() {
//         _glassesOffset = Offset(size.width / 2 - 80, size.height / 2 - 40);
//       });
//     }
//   }

//   Future<void> incrementHairstylePopularity(String id) async {
//     final url = ApiConfig.getIncrementPopularityUri(id);
//     try {
//       await http.post(url);
//     } catch (e) {
//       print('Error incrementing popularity: $e');
//     }
//   }

//   Future<void> _saveImage() async {
//     try {
//       if (_selectedHair.isEmpty) return;

//       final boundary =
//           _imageKey.currentContext?.findRenderObject()
//               as RenderRepaintBoundary?;
//       if (boundary == null) return;

//       final image = await boundary.toImage(pixelRatio: 3.0);
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       if (byteData == null) return;

//       final pngBytes = byteData.buffer.asUint8List();
//       final directory = await getApplicationDocumentsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final imagePath = '${directory.path}/hairstyle_$timestamp.png';
//       await File(imagePath).writeAsBytes(pngBytes);

//       if (mounted) {
//         showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text('✅ Success'),
//                 content: Text('Image saved successfully at:\n$imagePath'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text('❌ Failed'),
//                 content: Text('Failed to save image:\n${e.toString()}'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//         );
//       }
//     }
//   }

//   void _openPanel(String type) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.black.withOpacity(0.3),
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.4,
//               minChildSize: 0.2,
//               maxChildSize: 0.8,
//               builder: (_, controller) {
//                 return Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   child: _buildPanelContent(type, setModalState),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildPanelContent(
//     String type,
//     void Function(void Function()) setModalState,
//   ) {
//     switch (type) {
//       case "Hair":
//         return Column(
//           children: [
//             _buildFaceShapeTabs(setModalState),
//             const SizedBox(height: 10),
//             Expanded(child: _buildHairSelectorGrid()),
//           ],
//         );
//       case "Glasses":
//         return Column(
//           children: [
//             _buildFaceShapeTabs(setModalState),
//             const SizedBox(height: 10),
//             Expanded(child: _buildGlassesSelectorGrid()),
//           ],
//         );

//       default:
//         return const SizedBox();
//     }
//   }

//   Widget _buildHairSelectorGrid() {
//     print("Current hairs count: ${currentHairOptions.length}");
//     return GridView.count(
//       crossAxisCount: 4,
//       crossAxisSpacing: 8,
//       mainAxisSpacing: 8,
//       children:
//           currentHairOptions.map((hairstyle) {
//             final hairUrl = "${ApiConfig.baseUrl}/public/hairstyles/${hairstyle.imageUrl}";
//             final selected = hairUrl == _selectedHair;
//             return GestureDetector(
//               onTap: () async {
//                 _fadeController.reset();
//                 setState(() => _selectedHair = hairUrl);
//                 _fadeController.forward();

//                 _resetHairPositionToCenter();

//                 await incrementHairstylePopularity(hairstyle.hairstyleId);

//                 if (widget.initialImage != null) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => TryOnScreenPageOriginal(
//                             hairstyle: hairstyle,
//                             capturedImage: widget.initialImage!,
//                             isMale: _isMale,
//                           ),
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: selected ? Colors.teal : Colors.grey,
//                     width: selected ? 3 : 1,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.all(4),
//                 child: Image.network(hairUrl, fit: BoxFit.contain),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildHairstylePanel() {
//     return Column(
//       children: [
//         // Face shape tabs row
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children:
//                 faceShapeTabs.map((shape) {
//                   final isSelected = shape == _selectedFaceShape;
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 6),
//                     child: ChoiceChip(
//                       label: Text(shape),
//                       selected: isSelected,
//                       selectedColor: Colors.teal,
//                       onSelected: (selected) {
//                         if (selected) {
//                           setState(() {
//                             _selectedFaceShape = shape;
//                           });

//                           // ✅ Fetch hairstyles for selected face shape and gender
//                           getRecommendedHairstyles(
//                             shape.toLowerCase(),
//                             widget.gender.toLowerCase(),
//                           );
//                         }
//                       },
//                     ),
//                   );
//                 }).toList(),
//           ),
//         ),

//         const SizedBox(height: 8),

//         // Hairstyle display
//         Expanded(
//           child:
//               currentHairOptions.isEmpty
//                   ? const Center(
//                     child: Text("No hairstyle recommendations available."),
//                   )
//                   : _buildHairSelectorGrid(),
//         ),
//       ],
//     );
//   }

//   //added part
//   Widget _buildGlassesPanel() {
//     return Column(
//       children: [
//         // Face shape tabs row
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children:
//                 faceShapeTabs.map((shape) {
//                   final isSelected = shape == _selectedGlassesFaceShape;
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 6),
//                     child: ChoiceChip(
//                       label: Text(shape),
//                       selected: isSelected,
//                       selectedColor: Colors.teal,
//                       onSelected: (selected) {
//                         if (selected) {
//                           setState(() {
//                             _selectedGlassesFaceShape = shape;
//                           });
//                           // Fetch glasses for new face shape tab
//                           getRecommendedGlasses(
//                             shape.toLowerCase(),
//                             widget.gender.toLowerCase(),
//                           );
//                         }
//                       },
//                     ),
//                   );
//                 }).toList(),
//           ),
//         ),

//         const SizedBox(height: 8),

//         // Show loading or glasses grid
//         Expanded(
//           child:
//               _isLoadingGlasses
//                   ? const Center(child: CircularProgressIndicator())
//                   : _recommendedGlasses.isEmpty
//                   ? const Center(
//                     child: Text("No glasses recommendations available."),
//                   )
//                   : _buildGlassesSelectorGrid(),
//         ),
//       ],
//     );
//   }

//   Widget _buildGlassesSelectorGrid() {
//     print("Building glasses grid with length: ${_recommendedGlasses.length}");
//     if (_recommendedGlasses.isEmpty) {
//       return const Center(child: Text("No glasses recommendations available."));
//     }

//     return GridView.count(
//       crossAxisCount: 4,
//       crossAxisSpacing: 8,
//       mainAxisSpacing: 8,
//       children:
//           _recommendedGlasses.map((glass) {
//             final selected =
//                 _recommendedGlasses.indexOf(glass) == _selectedGlassesIndex;
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedGlassesIndex = _recommendedGlasses.indexOf(glass);
//                   _resetGlassesPositionToCenter();
//                 });

//                 if (widget.initialImage != null) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => TryOnGlassesScreen(
//                             capturedImage: widget.initialImage!,
//                             glassesImageUrl:
//                                 "${ApiConfig.baseUrl}/public/glasses/${glass.imageUrl}",
//                           ),
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: selected ? Colors.teal : Colors.grey,
//                     width: selected ? 3 : 1,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.all(4),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Image.network(
//                         "${ApiConfig.baseUrl}/public/glasses/${glass.imageUrl}",
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       glass.glassesName,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: selected ? Colors.teal : Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   double _angleBetweenVectors(Offset v1, Offset v2) {
//     final angle1 = math.atan2(v1.dy, v1.dx);
//     final angle2 = math.atan2(v2.dy, v2.dx);
//     return angle2 - angle1;
//   }

//   void _resizeHair(String handle, DragUpdateDetails details) {
//     const double minSize = 50;
//     const double maxSize = 400;
//     double boxWidth = 160 * _hairScaleX;
//     double boxHeight = 160 * _hairScaleY;
//     Offset newOffset = _hairOffset;

//     double widthChange = 0;
//     double heightChange = 0;

//     switch (handle) {
//       case 'topLeft':
//         widthChange = -details.delta.dx;
//         heightChange = -details.delta.dy;
//         newOffset += Offset(details.delta.dx, details.delta.dy);
//         break;
//       case 'top':
//         heightChange = -details.delta.dy;
//         newOffset += Offset(0, details.delta.dy);
//         break;
//       case 'topRight':
//         widthChange = details.delta.dx;
//         heightChange = -details.delta.dy;
//         newOffset += Offset(0, details.delta.dy);
//         break;
//       case 'right':
//         widthChange = details.delta.dx;
//         break;
//       case 'bottomRight':
//         widthChange = details.delta.dx;
//         heightChange = details.delta.dy;
//         break;
//       case 'bottom':
//         heightChange = details.delta.dy;
//         break;
//       case 'bottomLeft':
//         widthChange = -details.delta.dx;
//         heightChange = details.delta.dy;
//         newOffset += Offset(details.delta.dx, 0);
//         break;
//       case 'left':
//         widthChange = -details.delta.dx;
//         newOffset += Offset(details.delta.dx, 0);
//         break;
//     }

//     double newWidth = boxWidth + widthChange;
//     double newHeight = boxHeight + heightChange;

//     // Constrain to min/max sizes
//     newWidth = newWidth.clamp(minSize, maxSize);
//     newHeight = newHeight.clamp(minSize, maxSize);

//     // Adjust offset if we hit size constraints
//     if (newWidth == minSize || newWidth == maxSize) {
//       newOffset = Offset(
//         _initialOffset.dx + (boxWidth - newWidth) * (widthChange < 0 ? 1 : 0),
//         newOffset.dy,
//       );
//     }
//     if (newHeight == minSize || newHeight == maxSize) {
//       newOffset = Offset(
//         newOffset.dx,
//         _initialOffset.dy +
//             (boxHeight - newHeight) * (heightChange < 0 ? 1 : 0),
//       );
//     }

//     setState(() {
//       _hairOffset = newOffset;
//       _hairScaleX = newWidth / 160;
//       _hairScaleY = newHeight / 160;
//     });
//   }

//   List<Widget> _buildResizeHandles(double boxWidth, double boxHeight) {
//     const double handleSize = 24.0;

//     final handles = <Map<String, dynamic>>[
//       {'name': 'topLeft', 'left': 0.0, 'top': 0.0},
//       {'name': 'top', 'left': boxWidth / 2 - handleSize / 2, 'top': 0.0},
//       {'name': 'topRight', 'left': boxWidth - handleSize, 'top': 0.0},
//       {
//         'name': 'right',
//         'left': boxWidth - handleSize,
//         'top': boxHeight / 2 - handleSize / 2,
//       },
//       {
//         'name': 'bottomRight',
//         'left': boxWidth - handleSize,
//         'top': boxHeight - handleSize,
//       },
//       {
//         'name': 'bottom',
//         'left': boxWidth / 2 - handleSize / 2,
//         'top': boxHeight - handleSize,
//       },
//       {'name': 'bottomLeft', 'left': 0.0, 'top': boxHeight - handleSize},
//       {'name': 'left', 'left': 0.0, 'top': boxHeight / 2 - handleSize / 2},
//     ];

//     return handles.map((handle) {
//       return Positioned(
//         left: handle['left'],
//         top: handle['top'],
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onPanUpdate: (details) {
//             _resizeHair(handle['name'], details);
//           },
//           child: Container(
//             width: handleSize,
//             height: handleSize,
//             decoration: BoxDecoration(
//               color: Colors.yellow,
//               border: Border.all(color: Colors.black, width: 1.5),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.teal[700],
//         title: const Text("Hairstyle Try-On"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildImagePreview(), // <-- Add this line
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedBottomTab,
//         onTap: (index) {
//           setState(() => _selectedBottomTab = index);
//           if (index == 0) _openPanel("Hair");
//           if (index == 1) _openPanel("Glasses");
//           if (index == 2) _openPanel("Editor");
//         },
//         selectedItemColor: Colors.teal,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.face), label: "Hairstyle"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.remove_red_eye),
//             label: "Glasses",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Editor"),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagePreview() {
//     return Expanded(
//       child: Center(
//         child:
//             widget.initialImage == null
//                 ? const Text("No image provided.")
//                 : LayoutBuilder(
//                   builder: (context, constraints) {
//                     return Stack(
//                       children: [
//                         SizedBox(
//                           key: _imageKey,
//                           width: constraints.maxWidth,
//                           height: constraints.maxHeight,
//                           child: Image.file(
//                             widget.initialImage!,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                         if (_selectedHair.isNotEmpty)
//                           Positioned(
//                             left: _hairOffset.dx,
//                             top: _hairOffset.dy,
//                             child: GestureDetector(
//                               onScaleStart: (d) {
//                                 _initialFocalPoint = d.focalPoint;
//                                 _initialOffset = _hairOffset;
//                                 _initialScale = _hairScale;
//                                 _initialRotation = _hairRotation;
//                               },
//                               onScaleUpdate: (d) {
//                                 setState(() {
//                                   final delta =
//                                       d.focalPoint - _initialFocalPoint;
//                                   _hairOffset = _initialOffset + delta;
//                                   _hairScale = (_initialScale * d.scale).clamp(
//                                     0.5,
//                                     3.0,
//                                   );
//                                   _hairRotation = _initialRotation + d.rotation;
//                                 });
//                               },
//                               child: FadeTransition(
//                                 opacity: _fadeAnimation,
//                                 child: Transform(
//                                   alignment: Alignment.center,
//                                   transform:
//                                       Matrix4.identity()
//                                         ..translate(60.0, 60.0)
//                                         ..rotateZ(_hairRotation)
//                                         ..scale(_hairScale)
//                                         ..translate(-60.0, -60.0),
//                                   child: Image.network(
//                                     _selectedHair,
//                                     width: 160,
//                                     height: 160,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (_selectedGlassesIndex != null)
//                           Positioned(
//                             left: _glassesOffset.dx,
//                             top: _glassesOffset.dy,
//                             child: GestureDetector(
//                               onScaleStart: (d) {
//                                 _initialFocalPoint = d.focalPoint;
//                                 _initialOffset = _glassesOffset;
//                                 _initialScale = _glassesScale;
//                                 _initialRotation = _glassesRotation;
//                               },
//                               onScaleUpdate: (d) {
//                                 setState(() {
//                                   final delta =
//                                       d.focalPoint - _initialFocalPoint;
//                                   _glassesOffset = _initialOffset + delta;
//                                   _glassesScale = (_initialScale * d.scale)
//                                       .clamp(0.5, 3.0);
//                                   _glassesRotation =
//                                       _initialRotation + d.rotation;
//                                 });
//                               },
//                               child: Transform(
//                                 alignment: Alignment.center,
//                                 transform:
//                                     Matrix4.identity()
//                                       ..translate(80.0, 40.0)
//                                       ..rotateZ(_glassesRotation)
//                                       ..scale(_glassesScale)
//                                       ..translate(-80.0, -40.0),
//                                 child: Image.network(
//                                   "${ApiConfig.baseUrl}/public/glasses/${_recommendedGlasses[_selectedGlassesIndex!].imageUrl}",
//                                   width: 160,
//                                   height: 80,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//       ),
//     );
//   }
// }
