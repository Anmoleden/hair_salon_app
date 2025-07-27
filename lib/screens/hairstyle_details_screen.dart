// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import '../models/hairstyle_model.dart';
// // ignore: unused_import
// import 'try_on_screen.dart';

// class HairstyleDetailsScreen extends StatefulWidget {
//   final Hairstyle hairstyle;
//   const HairstyleDetailsScreen({super.key, required this.hairstyle});

//   @override
//   State<HairstyleDetailsScreen> createState() => _HairstyleDetailsScreenState();
// }

// class _HairstyleDetailsScreenState extends State<HairstyleDetailsScreen> {
//   late bool isFavorite;
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     isFavorite = widget.hairstyle.isFavorite;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hairstyle = widget.hairstyle;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: Text(
//           'Hairstyle Details',
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Image.network(
//                   hairstyle.representingImageUrl,
//                   width: double.infinity,
//                   height: 260,
//                   fit: BoxFit.cover,
//                   errorBuilder:
//                       (_, __, ___) => const SizedBox(
//                         height: 260,
//                         child: Center(
//                           child: Icon(Icons.broken_image, size: 50),
//                         ),
//                       ),
//                 ),
//                 Positioned(
//                   top: 16,
//                   right: 60,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.black54,
//                     child: IconButton(
//                       icon: Icon(
//                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           isFavorite = !isFavorite;
//                           hairstyle.isFavorite = isFavorite;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 16,
//                   right: 10,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.black54,
//                     child: IconButton(
//                       icon: const Icon(Icons.share, color: Colors.white),
//                       onPressed: () {
//                         // Add share logic if needed
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Hairstyle Name
//                   Text(
//                     hairstyle.hairstyleName,
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   // Gender & Category Tags
//                   Wrap(
//                     spacing: 10,
//                     children: [
//                       _buildTag(hairstyle.gender),
//                       _buildTag(hairstyle.category),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // Placeholder Description
//                   Text(
//                     "This hairstyle works well with the selected face shape. You can try it on to see how it fits your look!",
//                     style: GoogleFonts.poppins(
//                       fontSize: 15.5,
//                       height: 1.6,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Suitable Face Shapes
//                   Text(
//                     "Suitable Face Shapes",
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 10,
//                     children:
//                         hairstyle.faceShapes
//                             .map((shape) => _buildTag(shape))
//                             .toList(),
//                   ),

//                   const SizedBox(height: 20),

//                   // Popularity (Static Placeholder for Now)
//                   Text(
//                     "Popularity",
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   LinearPercentIndicator(
//                     lineHeight: 8.0,
//                     percent: 0.85, // Replace with dynamic value if available
//                     progressColor: Colors.pinkAccent,
//                     backgroundColor: Colors.grey[300],
//                     barRadius: const Radius.circular(16),
//                     animation: true,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "85%",
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Try On Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         padding: EdgeInsets.zero,
//                         backgroundColor: Colors.transparent,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => TryOnScreenPage(
//                                   hairstyle: hairstyle,
//                                   capturedImage: _capturedImage!,
//                                 ),
//                           ),
//                         );
//                       },
//                       child: Ink(
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFFFF5F6D), Color(0xFF8456EC)],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Try On This Hairstyle",
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTag(String text, {Color color = const Color(0xFFF4F4F4)}) {
//     return Chip(
//       backgroundColor: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       label: Text(
//         text,
//         style: GoogleFonts.poppins(
//           fontSize: 13,
//           color: color == const Color(0xFFF4F4F4) ? Colors.black : Colors.white,
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../classifiers/hairstyle_model.dart';
import '../services/favorite_services.dart';
import 'try_on_screen.dart';
import 'package:share_plus/share_plus.dart';
import "../config/api_config.dart";

class HairstyleDetailsScreen extends StatefulWidget {
  final Hairstyle hairstyle;
  final File? capturedImage; // <-- add capturedImage here

  const HairstyleDetailsScreen({
    super.key,
    required this.hairstyle,
    this.capturedImage, // optional
  });

  @override
  State<HairstyleDetailsScreen> createState() => _HairstyleDetailsScreenState();
}

class _HairstyleDetailsScreenState extends State<HairstyleDetailsScreen> {
  late bool isFavorite;
  final storage = FlutterSecureStorage();
  bool isProcessingFavorite = false;

  final GlobalKey _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    isFavorite = widget.hairstyle.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isProcessingFavorite = true;
    });

    final userId = await storage.read(key: 'userId');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      setState(() {
        isProcessingFavorite = false;
      });
      return;
    }

    try {
      if (!isFavorite) {
        // Add to favorites
        await FavoriteService.addFavorite(userId, widget.hairstyle.id);
        setState(() {
          isFavorite = true;
          widget.hairstyle.isFavorite = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      } else {
        // If you have a removeFavorite method, call it here:
        // await FavoriteService.removeFavorite(userId, widget.hairstyle.id);
        // For now, just notify user favorites removal is not implemented
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Remove favorite not implemented')),
        // );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update favorites: $e')));
    } finally {
      setState(() {
        isProcessingFavorite = false;
      });
    }
  }

  // Future<void> _shareHairstyleWithImage(Hairstyle hairstyle) async {
  //   try {
  //     // Download image
  //     final response = await http.get(Uri.parse(hairstyle.representingImageUrl));
  //     final bytes = response.bodyBytes;

  //     // Get temp directory
  //     final tempDir = await getTemporaryDirectory();
  //     final file = File('${tempDir.path}/${hairstyle.hairstyleName}.png');

  //     // Save image to file
  //     await file.writeAsBytes(bytes);

  //     // Share text and image
  //     await Share.shareXFiles(
  //       [XFile(file.path)],
  //       text: '''
  //       Check out this hairstyle!

  //       Name: ${hairstyle.hairstyleName}
  //       Description: ${hairstyle.description}
  //      ''',
  //     );
  //   } catch (e) {
  //     print('Error sharing hairstyle: $e');
  //   }
  // }

  Future<void> _shareHairstyleUIAsImage() async {
    try {
      RenderRepaintBoundary boundary =
          _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hairstyle_share.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Check out this hairstyle from our app!");
    } catch (e) {
      print("Error sharing styled screenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final hairstyle = widget.hairstyle;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Hairstyle Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RepaintBoundary(
        key: _shareKey,
        child: Container(
          color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                     "${ApiConfig.baseUrl}/public/hairstyles/${hairstyle.representingImageUrl}",
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const SizedBox(
                          height: 260,
                          child: Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                  ),
                  Positioned(
                    top: 15,
                    right: 60,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon:
                            isProcessingFavorite
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                        onPressed:
                            isProcessingFavorite ? null : _toggleFavorite,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          // Add share logic if needed
                          _shareHairstyleUIAsImage();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hairstyle Name
                    Text(
                      hairstyle.hairstyleName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Gender & Category Tags
                    Wrap(
                      spacing: 10,
                      children: [
                        _buildTag(hairstyle.gender),
                        _buildTag(hairstyle.category),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Placeholder Description
                    Text(
                      "This hairstyle works well with the selected face shape. You can try it on to see how it fits your look!",
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Suitable Face Shapes
                    Text(
                      "Suitable Face Shapes",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children:
                          hairstyle.faceShapes
                              .map((shape) => _buildTag(shape))
                              .toList(),
                    ),

                    const SizedBox(height: 20),

                    // Popularity (Static Placeholder for Now)
                    Text(
                      "Popularity",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: (hairstyle.popularity / 10).clamp(0, 1),
                      progressColor: Colors.pinkAccent,
                      backgroundColor: Colors.grey[300],
                      barRadius: const Radius.circular(16),
                      animation: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(hairstyle.popularity * 10).clamp(0, 100).toInt()}%",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Try On Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed:
                            widget.capturedImage == null
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => TryOnScreenPage(
                                            hairstyle: hairstyle,
                                            capturedImage:
                                                widget.capturedImage!,
                                                isMale: hairstyle.gender.toLowerCase() == "male",
                                          ),
                                    ),
                                  );
                                },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient:
                                widget.capturedImage == null
                                    ? null
                                    : const LinearGradient(
                                      colors: [
                                        Color(0xFFFF5F6D),
                                        Color(0xFF8456EC),
                                      ],
                                    ),
                            color:
                                widget.capturedImage == null
                                    ? Colors.grey.shade400
                                    : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              widget.capturedImage == null
                                  ? "Please capture a photo first"
                                  : "Try On This Hairstyle",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color:
                                    widget.capturedImage == null
                                        ? Colors.white70
                                        : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTag(String text, {Color color = const Color(0xFFF4F4F4)}) {
    return Chip(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: color == const Color(0xFFF4F4F4) ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
