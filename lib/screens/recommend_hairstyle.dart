import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // Add this import for InputImage

import '../classifiers/hairstyle_model.dart';
import '../classifiers/glasses_model.dart';
import '../config/api_config.dart';
import '../services/favorite_services.dart';
import 'gallery_view_direct.dart';
import 'try_on_glasses.dart';

class RecommendationPageHairstyle extends StatefulWidget {
  final String faceShape;
  final String gender;
  final File? croppedImage;

  const RecommendationPageHairstyle({
    super.key,
    required this.faceShape,
    required this.gender,
    this.croppedImage,
  });

  @override
  State<RecommendationPageHairstyle> createState() =>
      _RecommendationPageHairstyleState();
}

class _RecommendationPageHairstyleState
    extends State<RecommendationPageHairstyle> {
  List<Hairstyle> hairstyleList = [];
  List<Glasses> recommendedGlasses = [];
  bool isLoading = true;
  bool isFetchingFavorites = true;
  bool isFetchingGlasses = true;

  Set<String> favoriteIds = {};
  Hairstyle? _selectedStyle;

  @override
  void initState() {
    super.initState();
    fetchHairstyles();
    fetchFavoriteIds();
    fetchRecommendedGlasses();
  }

  Future<void> fetchHairstyles() async {
    try {
      final uri = ApiConfig.getRecommendHairstylesUri(
        widget.faceShape,
        widget.gender,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          hairstyleList = data.map((json) => Hairstyle.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching hairstyles: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRecommendedGlasses() async {
    try {
      final uri = ApiConfig.getRecommendGlassesUri(
        widget.faceShape,
        widget.gender,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          recommendedGlasses =
              data.map((json) => Glasses.fromJson(json)).toList();
          isFetchingGlasses = false;
        });
      } else {
        setState(() => isFetchingGlasses = false);
      }
    } catch (e) {
      print("Error fetching glasses: $e");
      setState(() => isFetchingGlasses = false);
    }
  }

  Future<void> fetchFavoriteIds() async {
    final userId = await FlutterSecureStorage().read(key: 'userId');
    if (userId == null) return;

    try {
      final favoriteHairstyles = await FavoriteService.fetchFavorites(userId);
      final ids = favoriteHairstyles.map((h) => h.id).toList();

      setState(() {
        favoriteIds = ids.toSet();
        isFetchingFavorites = false;
      });
    } catch (e) {
      print("Error fetching favorites: $e");
      setState(() => isFetchingFavorites = false);
    }
  }

  Future<void> toggleFavorite(String hairstyleId) async {
    final userId = await FlutterSecureStorage().read(key: 'userId');
    if (userId == null) return;

    try {
      if (favoriteIds.contains(hairstyleId)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Already in favorites")));
      } else {
        await FavoriteService.addFavorite(userId, hairstyleId);
        setState(() {
          favoriteIds.add(hairstyleId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to favorites!")));
      }
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Recommendations for ${widget.faceShape} "),
        backgroundColor: Colors.teal,
      ),
      body:
          isLoading || isFetchingFavorites
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hairstyle Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Center(
                        child: Text(
                          "Hairstyles",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    GridView.builder(
                      itemCount: hairstyleList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        final style = hairstyleList[index];
                        final isSelected = _selectedStyle == style;

                        return Material(
                          borderRadius: BorderRadius.circular(16),
                          elevation: 6,
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStyle = style);
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    "${ApiConfig.baseUrl}/public/hairstyles/${style.representingImageUrl}",
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                  ),
                                ),
                                if (style.isTrending)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Trending",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => toggleFavorite(style.id),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.9,
                                      ),
                                      child: Icon(
                                        favoriteIds.contains(style.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.pinkAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withAlpha(180),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          style.hairstyleName,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          style.gender,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.tealAccent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Glasses Section
                    if (!isFetchingGlasses && recommendedGlasses.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Center(
                          child: Text(
                            "Glasses",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!isFetchingGlasses && recommendedGlasses.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recommendedGlasses.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) {
                          final glasses = recommendedGlasses[index];
                          final imageUrl =
                              "${ApiConfig.baseUrl}/public/glasses/${glasses.imageUrl}";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TryOnGlassesScreen(
                                        capturedImage: widget.croppedImage!,
                                        glassesImageUrl: imageUrl,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (_, __, ___) => const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    glasses.glassesName,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

      // For Try Hairstyle Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cut),
            label: const Text("Try Hairstyle"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.pinkAccent,
            ),
            onPressed: () {
              if (widget.croppedImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No cropped image available')),
                );
                return;
              }

                 Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GalleryViewDirect(
                                title: 'Gallery',
                                onImage: (InputImage inputImage) async {
                                  // This will be filled in the next step
                                },
                                onDetectorViewModeChanged: () {},
                                isTryHairstyleFlow: true,
                                gender:widget.gender,
                              ),
                        ),
                      );
            },
          ),
        ),
      ),
    );
  }
}
