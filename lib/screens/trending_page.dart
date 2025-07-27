import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../classifiers/hairstyle_model.dart';
import '../classifiers/filters_model.dart';
import '../services/trending_services.dart';
import '../services/favorite_services.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../screens/hairstyle_details_screen.dart';
import '../screens/try_on_screen.dart';
import '../config/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<Hairstyle> allHairstyles = [];
  List<Hairstyle> filteredHairstyles = [];
  Filters currentFilters = Filters();
  bool isLoading = true;
  String? errorMessage;
  File? _capturedImage;

  Set<String> favoriteIds = {};
  bool isFetchingFavorites = true;

  @override
  void initState() {
    super.initState();
    fetchHairstyles();
    fetchFavoriteIds();
  }

  Future<void> fetchHairstyles() async {
    try {
      final fetchedStyles = await ApiService.fetchTrendingHairstyles();
      fetchedStyles.sort((a, b) => b.popularity.compareTo(a.popularity));
      for (int i = 0; i < fetchedStyles.length; i++) {
        fetchedStyles[i].isTrending = i < 5;
      }

      setState(() {
        allHairstyles = fetchedStyles;
        isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load hairstyles. Please try again.';
        isLoading = false;
      });
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

  void _applyFilters() {
    setState(() {
      filteredHairstyles =
          allHairstyles.where((style) {
            return currentFilters.apply(style.gender, style.category ?? '');
          }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => FilterBottomSheet(
            currentFilters: currentFilters,
            onApply: (filters) {
              currentFilters = filters;
              _applyFilters();
            },
            showGenderFilter: true,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trending',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          TextButton.icon(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
            label: Text(
              "Filters",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body:
          isLoading || isFetchingFavorites
              ? const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              )
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: GoogleFonts.poppins()))
              : filteredHairstyles.isEmpty
              ? Center(
                child: Text(
                  "No hairstyles found.",
                  style: GoogleFonts.poppins(),
                ),
              )
              : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return Padding(
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
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HairstyleDetailsScreen(hairstyle: style),
                    ),
                  ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      "${ApiConfig.baseUrl}/public/hairstyles/${style.representingImageUrl}",
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
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
                        backgroundColor: Colors.white.withOpacity(0.9),
                        // child: Icon(
                        //   style.isFavorite ? Icons.favorite : Icons.favorite_border,
                        //   color: Colors.pinkAccent,
                        //   size: 18,
                        // ),
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
                          ElevatedButton(
                            onPressed: () {
                              if (_capturedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please take a photo first'),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TryOnScreenPage(
                                          hairstyle: style,
                                          capturedImage: _capturedImage!,
                                          isMale:
                                              style.gender.toLowerCase() ==
                                              "male",
                                        ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Try On",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }
}
class _NetworkImageWithShimmer extends StatelessWidget {
  final String url;
  const _NetworkImageWithShimmer({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      ),
    );
  }
}