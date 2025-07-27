import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hair_salon/screens/try_on_hairstyle.dart';
import 'package:hair_salon/widgets/filter_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../classifiers/hairstyle_model.dart';
//import '../models/hairstyle_model.dart';
import '../services/favorite_services.dart';
import '../config/api_config.dart';
import '../classifiers/filters_model.dart';

class RecommendationPage extends StatefulWidget {
  final String faceShape;
  final String gender;
  final File capturedImage; // ← From TryOnScreenPage

  const RecommendationPage({
    super.key,
    required this.faceShape,
    required this.gender,
    required this.capturedImage,
  });

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  List<Hairstyle> recommendedHairstyles = [];
  List<Hairstyle> filteredHairstyles = [];
  bool isLoading = true;
  String? errorMessage;

  late Filters filters;

  @override
  void initState() {
    super.initState();
    //filters = Filters(gender: "All", category: "All"); // default filters
    filters = Filters(gender: widget.gender, length: "All");
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      final uri = ApiConfig.getRecommendHairstylesUri(
        widget.faceShape,
        widget.gender,

      );
      print("Requesting: $uri");

      final response = await http.get(uri);
      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Hairstyle> recommended =
            data.map((json) => Hairstyle.fromJson(json)).toList();

        // ✅ Check for favorites
        final userId = await FlutterSecureStorage().read(key: 'userId');
        if (userId != null) {
          final favorites = await FavoriteService.fetchFavorites(userId);
          final favoriteIds = favorites.map((fav) => fav.id).toSet();

          // ✅ Set isFavorite = true for matching items
          for (var style in recommended) {
            if (favoriteIds.contains(style.id)) {
              style.isFavorite = true;
            }
          }
        }

        setState(() {
          recommendedHairstyles = recommended;
          filteredHairstyles = List.from(recommendedHairstyles);
          isLoading = false;
        });

        _applyFilters();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredHairstyles =
          recommendedHairstyles.where((style) {
            final matchesGender =
                filters.gender == "All" ||
                style.gender.toLowerCase() == filters.gender.toLowerCase();
            final matchesCategory =
                filters.length == "All" ||
                style.category.toLowerCase() == filters.length.toLowerCase();
            return matchesGender && matchesCategory;
          }).toList();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => FilterBottomSheet(
            currentFilters: filters,
            onApply: (newFilters) {
              setState(() {
                filters = newFilters;
                _applyFilters();
              });
            },
            showGenderFilter: false, // hide gender filter here
          ),
    );
  }

  void toggleFavorite(Hairstyle style) async {
    final userId = await FlutterSecureStorage().read(key: 'userId');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      if (!style.isFavorite) {
        await FavoriteService.addFavorite(userId, style.id);
        setState(() {
          style.isFavorite = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to favorites!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Already in favorites')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Recommended for ${widget.faceShape} Face",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.pinkAccent),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              )
              : filteredHairstyles.isEmpty
              ? Center(
                child: Text(
                  "No recommendations found.",
                  style: GoogleFonts.poppins(),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: filteredHairstyles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final style = filteredHairstyles[index];
                    return Material(
                      borderRadius: BorderRadius.circular(16),
                      elevation: 6,
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => TryOnHairstyles(
                                    hairstyle: style,
                                    capturedImage: widget.capturedImage,
                                    isMale:
                                        widget.gender.toLowerCase() == "male",
                                  ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                style.representingImageUrl,
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
                            //for favorites
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => toggleFavorite(style),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.9,
                                  ),
                                  child: Icon(
                                    style.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.pinkAccent,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            //
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
