// edit the flutter code changing the ui of the image overlay tabs, The group of tabs short, medium, long, male and female should be expandable from bottom of the screen, it hides below when option (hair overlay) or user image is clicked and expands above the user image when one tab( short, medium, long, male or female) is clicked..                                                                                                                                       import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'take_photo_page.dart';
// import '../screens/hairstyle_details_screen.dart';
// import '../models/hairstyle_model.dart';

// class TryHairstyles extends StatefulWidget {
//   final File? croppedImage;
//   const TryHairstyles({super.key, this.croppedImage});

//   @override
//   State<TryHairstyles> createState() => _TryHairstylesState();
// }

// class _TryHairstylesState extends State<TryHairstyles>
//     with TickerProviderStateMixin {
//   List<CameraDescription>? _cameras;
//   late final FaceDetector _faceDetector;
//   List<Face> _faces = [];
//   File? _capturedImage;

//   bool _isMale = true;
//   bool _autoAlignHair = true;
//   String selectedCategory = "Short";
//   int _selectedBottomTab = 0;

//   Offset _hairOffset = const Offset(100, 150);
//   double _hairScale = 1.0;
//   double _hairRotation = 0.0;

//   Offset _initialFocalPoint = Offset.zero;
//   Offset _initialOffset = Offset.zero;
//   double _initialScale = 1.0;
//   double _initialRotation = 0.0;

//   final GlobalKey _imageKey = GlobalKey();
//   String resultText = "Tap the camera icon to take a photo.";
//   String _selectedHair = '';
//   String _selectedGlasses = '';

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   final Map<String, List<String>> maleHairs = {
//     "Short": ['assets/hairs/short1.png', 'assets/hairs/short2.png'],
//     "Medium": ['assets/hairs/med1.png', 'assets/hairs/med2.png'],
//     "Long": ['assets/hairs/long1.png'],
//   };

//   final Map<String, List<String>> femaleHairs = {
//     "Short": ['assets/hairs/f_short1.png'],
//     "Medium": ['assets/hairs/f_med1.png'],
//     "Long": ['assets/hairs/f_long1.png', 'assets/hairs/f_long2.png'],
//   };

//   final List<String> glassesList = [
//     'assets/glasses/glass1.png',
//     'assets/glasses/glass2.png',
//   ];

//   List<String> get currentHairOptions =>
//       _isMale
//           ? maleHairs[selectedCategory] ?? []
//           : femaleHairs[selectedCategory] ?? [];

//   bool tabsAboveImage = false;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.accurate,
//         enableLandmarks: true,
//         enableContours: true,
//       ),
//     );
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (widget.croppedImage != null && _capturedImage == null) {
//       setState(() {
//         _capturedImage = widget.croppedImage;
//         resultText = "Face detected! Drag, resize or rotate hair.";
//       });
//     }
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//   }

//   Future<void> _captureFromCamera() async {
//     final frontCamera = _cameras!.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//     );

//     final image = await Navigator.push<File>(
//       context,
//       MaterialPageRoute(builder: (_) => TakePhotoPage(camera: frontCamera)),
//     );

//     if (image != null) {
//       final inputImage = InputImage.fromFile(image);
//       final faces = await _faceDetector.processImage(inputImage);

//       setState(() {
//         _capturedImage = image;
//         _faces = faces;
//         resultText =
//             faces.isEmpty
//                 ? "No face found. Try again."
//                 : "Face detected! Drag, resize or rotate hair.";

//         if (_autoAlignHair && faces.isNotEmpty) {
//           final face = faces.first;
//           final rect = face.boundingBox;
//           _hairOffset = Offset(rect.left - 20, rect.top - 60);
//           _hairScale = 1.0;
//           _hairRotation = 0.0;
//         }
//       });
//     }
//   }

//   void _resetHairPositionToCenter() {
//     final context = _imageKey.currentContext;
//     if (context != null) {
//       final box = context.findRenderObject() as RenderBox;
//       final size = box.size;
//       setState(() {
//         _hairOffset = Offset(size.width / 2 - 60, size.height / 2 - 60);
//         _hairScale = 1.0;
//         _hairRotation = 0.0;
//       });
//     }
//   }

//   void _openPanel(String type) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.black.withValues(alpha: 0.3),
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.4,
//               minChildSize: 0.2,
//               maxChildSize: 0.8,
//               builder:
//                   (_, controller) => Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(20),
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     child:
//                         type == "Hair"
//                             ? Column(
//                               children: [
//                                 _buildCategoryTabs(setModalState),
//                                 const SizedBox(height: 10),
//                                 Expanded(child: _buildHairSelectorGrid()),
//                               ],
//                             )
//                             : type == "Glasses"
//                             ? _buildGlassesGrid(setModalState)
//                             : _buildSettings(),
//                   ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildCategoryTabs(void Function(void Function()) setModalState) {
//     final Map<String, List<String>> hairMap = _isMale ? maleHairs : femaleHairs;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children:
//           hairMap.keys.map((category) {
//             final selected = selectedCategory == category;
//             return GestureDetector(
//               onTap: () {
//                 setModalState(() {
//                   selectedCategory = category;
//                   _selectedHair = '';
//                 });
//                 setState(() {});
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: selected ? Colors.teal[600] : Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected ? Colors.teal : Colors.grey.shade300,
//                     width: 2,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildHairSelectorGrid() {
//     return GridView.count(
//       crossAxisCount: 4,
//       crossAxisSpacing: 8,
//       mainAxisSpacing: 8,
//       children:
//           currentHairOptions.map((hair) {
//             final selected = hair == _selectedHair;
//             return GestureDetector(
//               onTap: () {
//                 _fadeController.reset();
//                 setState(() => _selectedHair = hair);
//                 _fadeController.forward();

//                 if (_autoAlignHair && _faces.isNotEmpty) {
//                   final face = _faces.first;
//                   final rect = face.boundingBox;
//                   _hairOffset = Offset(rect.left - 20, rect.top - 60);
//                   _hairScale = 1.0;
//                   _hairRotation = 0.0;
//                 } else {
//                   _resetHairPositionToCenter();
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
//                 child: Image.asset(hair, fit: BoxFit.contain),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildGlassesGrid(void Function(void Function()) setModalState) {
//     return GridView.count(
//       crossAxisCount: 4,
//       crossAxisSpacing: 8,
//       mainAxisSpacing: 8,
//       children:
//           glassesList.map((glass) {
//             final selected = glass == _selectedGlasses;
//             return GestureDetector(
//               onTap: () {
//                 setModalState(() {
//                   _selectedGlasses = glass;
//                 });
//                 setState(() {});
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
//                 child: Image.asset(glass, fit: BoxFit.contain),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildSettings() {
//     return ListView(
//       children: [
//         SwitchListTile(
//           title: const Text("Auto-align Hair"),
//           value: _autoAlignHair,
//           onChanged: (val) {
//             setState(() => _autoAlignHair = val);
//             Navigator.pop(context);
//           },
//         ),
//         ListTile(
//           title: const Text("Reset Hair Position"),
//           trailing: const Icon(Icons.refresh),
//           onTap: () {
//             Navigator.pop(context);
//             _resetHairPositionToCenter();
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.teal[700],
//         title: const Text("Hairstyle Try-On"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: _captureFromCamera,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Fullscreen image with overlay
//           if (_capturedImage != null)
//             Positioned.fill(
//               child: Image.file(_capturedImage!, fit: BoxFit.cover),
//             )
//           else
//             Positioned.fill(child: _buildImagePreview()),
//           // Overlay: tabs and hair list
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.only(
//                 top: 32,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.45),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildGenderCategoryTabs(),
//                   const SizedBox(height: 8),
//                   SizedBox(height: 120, child: _buildHairSelectorGrid()),
//                 ],
//               ),
//             ),
//           ),
//           // Overlay: hair/glasses on image
//           if (_selectedHair.isNotEmpty && _capturedImage != null)
//             Positioned.fill(
//               child: GestureDetector(
//                 onScaleStart: (details) {
//                   _initialFocalPoint = details.focalPoint;
//                   _initialOffset = _hairOffset;
//                   _initialScale = _hairScale;
//                   _initialRotation = _hairRotation;
//                 },
//                 onScaleUpdate: (details) {
//                   setState(() {
//                     final delta = details.focalPoint - _initialFocalPoint;
//                     _hairOffset = _initialOffset + delta;
//                     _hairScale = (_initialScale * details.scale).clamp(
//                       0.5,
//                       3.0,
//                     );
//                     _hairRotation = _initialRotation + details.rotation;
//                   });
//                 },
//                 child: Stack(
//                   children: [
//                     Transform(
//                       alignment: Alignment.center,
//                       transform:
//                           Matrix4.identity()
//                             ..translate(_hairOffset.dx, _hairOffset.dy)
//                             ..translate(60.0, 60.0)
//                             ..rotateZ(_hairRotation)
//                             ..scale(_hairScale)
//                             ..translate(-60.0, -60.0),
//                       child: FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: SizedBox(
//                           width: 160,
//                           height: 160,
//                           child: Image.asset(
//                             _selectedHair,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (_selectedGlasses.isNotEmpty)
//                       Positioned(
//                         top: _hairOffset.dy + 80,
//                         left: _hairOffset.dx + 20,
//                         child: Image.asset(
//                           _selectedGlasses,
//                           width: 100,
//                           height: 40,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           // Overlay: result text at bottom
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 32,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Text(
//                   resultText,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: null,
//     );
//   }

//   Widget _buildGenderCategoryTabs() {
//     final List<String> tabs = ['Female', 'Short', 'Medium', 'Male', 'Long'];
//     int selectedIndex = 0;
//     if (_isMale) selectedIndex = 3;
//     if (selectedCategory == 'Short') selectedIndex = _isMale ? 3 : 1;
//     if (selectedCategory == 'Medium') selectedIndex = _isMale ? 3 : 2;
//     if (selectedCategory == 'Long') selectedIndex = 4;
//     return Container(
//       height: 48,
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: tabs.length,
//         itemBuilder: (context, index) {
//           bool selected = index == selectedIndex;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 tabsAboveImage = !tabsAboveImage;
//                 if (tabs[index] == 'Female') {
//                   _isMale = false;
//                   selectedCategory = 'Short';
//                   _selectedHair = '';
//                 } else if (tabs[index] == 'Male') {
//                   _isMale = true;
//                   selectedCategory = 'Short';
//                   _selectedHair = '';
//                 } else if (tabs[index] == 'Short') {
//                   selectedCategory = 'Short';
//                   _selectedHair = '';
//                 } else if (tabs[index] == 'Medium') {
//                   selectedCategory = 'Medium';
//                   _selectedHair = '';
//                 } else if (tabs[index] == 'Long') {
//                   selectedCategory = 'Long';
//                   _selectedHair = '';
//                 }
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
//               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//               decoration: BoxDecoration(
//                 color: selected ? Colors.teal : Colors.transparent,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Center(
//                 child: Text(
//                   tabs[index],
//                   style: TextStyle(
//                     color: selected ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildImagePreview() {
//     return Expanded(
//       child: Center(
//         child:
//             _capturedImage == null
//                 ? Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.camera_alt_outlined,
//                       size: 80,
//                       color: Colors.teal[300],
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       "Tap the camera icon to take a photo.",
//                       style: TextStyle(color: Colors.teal[700], fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 )
//                 : LayoutBuilder(
//                   builder: (context, constraints) {
//                     final maxWidth = constraints.maxWidth;
//                     final maxHeight = constraints.maxHeight;
//                     return Stack(
//                       children: [
//                         Container(
//                           key: _imageKey,
//                           width: maxWidth,
//                           height: maxHeight,
//                           child: Image.file(
//                             _capturedImage!,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                         if (_faces.isNotEmpty && _selectedHair.isNotEmpty)
//                           Positioned(
//                             left: _hairOffset.dx,
//                             top: _hairOffset.dy,
//                             child: GestureDetector(
//                               onScaleStart: (details) {
//                                 _initialFocalPoint = details.focalPoint;
//                                 _initialOffset = _hairOffset;
//                                 _initialScale = _hairScale;
//                                 _initialRotation = _hairRotation;
//                               },
//                               onScaleUpdate: (details) {
//                                 setState(() {
//                                   if (!_autoAlignHair) {
//                                     final delta =
//                                         details.focalPoint - _initialFocalPoint;
//                                     _hairOffset = _initialOffset + delta;
//                                   }
//                                   _hairScale = (_initialScale * details.scale)
//                                       .clamp(0.5, 3.0);
//                                   _hairRotation =
//                                       _initialRotation + details.rotation;
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
//                                   child: SizedBox(
//                                     width: 160,
//                                     height: 160,
//                                     child: Stack(
//                                       alignment: Alignment.center,
//                                       children: [
//                                         Image.asset(
//                                           _selectedHair,
//                                           fit: BoxFit.contain,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (_selectedGlasses.isNotEmpty)
//                           Positioned(
//                             top: _hairOffset.dy + 80,
//                             left: _hairOffset.dx + 20,
//                             child: Image.asset(
//                               _selectedGlasses,
//                               width: 100,
//                               height: 40,
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