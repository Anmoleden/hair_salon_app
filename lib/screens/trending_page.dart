import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hairstyle_model.dart';
import '../models/filters_model.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../screens/hairstyle_details_screen.dart';
import '../screens/try_on_screen.dart';

class TrendingPage extends StatefulWidget {
  final bool showFavoritesOnly;

  const TrendingPage({super.key, required this.showFavoritesOnly});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<Hairstyle> allHairstyles = [
    Hairstyle(
      imageUrl: "https://i.imgur.com/3yNCE0N.jpg",
      title: "Classic Bob",
      gender: "Female",
      length: "Medium",
      isTrending: true,
      isFavorite: false,
      tags: ['Classic', 'Bob', 'Medium'],
      description: 'A timeless classic bob haircut with a modern twist.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
    Hairstyle(
      imageUrl: "https://i.imgur.com/xvw3VZk.jpg",
      title: "Textured Crop",
      gender: "Male",
      length: "Short",
      isTrending: true,
      isFavorite: false,
      tags: ['Textured', 'Crop', 'Short'],
      description: 'A stylish textured crop haircut for men.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
    Hairstyle(
      imageUrl: "https://i.imgur.com/KO5WzwP.jpg",
      title: "Long Waves",
      gender: "Female",
      length: "Long",
      isTrending: true,
      isFavorite: true,
      tags: ['Long', 'Wavy', 'Elegant'],
      description: 'Soft and elegant long wavy hairstyle.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
    Hairstyle(
      imageUrl: "https://i.imgur.com/VbE2zRt.jpg",
      title: "Undercut",
      gender: "Male",
      length: "Short",
      isTrending: true,
      isFavorite: false,
      tags: ['Undercut', 'Sharp', 'Short'],
      description: 'A bold undercut haircut with clean edges.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
    Hairstyle(
      imageUrl: "https://i.imgur.com/zOf4F2A.jpg",
      title: "Pixie Cut",
      gender: "Female",
      length: "Short",
      isTrending: true,
      isFavorite: false,
      tags: ['Pixie', 'Short', 'Bold'],
      description: 'A daring pixie cut for confident personalities.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
    Hairstyle(
      imageUrl: "https://i.imgur.com/ISHRVHI.jpg",
      title: "Shoulder Length",
      gender: "Female",
      length: "Medium",
      isTrending: true,
      isFavorite: true,
      tags: ['Shoulder', 'Medium', 'Casual'],
      description: 'Casual and versatile shoulder length hairstyle.',
      faceShape: "Oval, Round, Heart",
      popularity: 0.92,
    ),
  ];

  Filters currentFilters = Filters();
  List<Hairstyle> filteredHairstyles = [];
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    showFavoritesOnly = widget.showFavoritesOnly;
    filteredHairstyles = List.from(allHairstyles);
    _applyFilters();
  }

  void toggleFavorite(Hairstyle style) {
    setState(() {
      style.isFavorite = !style.isFavorite;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredHairstyles =
          allHairstyles.where((style) {
            bool matchesFilter = currentFilters.apply(
              style.gender,
              style.length,
            );
            bool matchesFavorite = !showFavoritesOnly || style.isFavorite;
            return matchesFilter && matchesFavorite;
          }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return FilterBottomSheet(
          currentFilters: currentFilters,
          onApply: (filters) {
            currentFilters = filters;
            _applyFilters();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          widget.showFavoritesOnly ? 'Favorites' : 'Trending',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        actions: [
          if (!widget.showFavoritesOnly)
            IconButton(
              tooltip: showFavoritesOnly ? 'Show All' : 'Show Favorites',
              icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: Colors.pinkAccent,
              ),
              onPressed: () {
                setState(() {
                  showFavoritesOnly = !showFavoritesOnly;
                  _applyFilters();
                });
              },
            ),
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child:
            filteredHairstyles.isEmpty
                ? Center(
                  child: Text(
                    "No hairstyles found for selected filters.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                : GridView.builder(
                  itemCount: filteredHairstyles.length,
                  physics: const BouncingScrollPhysics(),
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
                                  (_) =>
                                      HairstyleDetailsScreen(hairstyle: style),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _NetworkImageWithShimmer(
                                url: style.imageUrl,
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
                                onTap: () => toggleFavorite(style),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
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
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${style.gender} · ${style.length}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => TryOnScreen(
                                                    hairstyle: style,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.pinkAccent,
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Try On",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
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
      ),
    );
  }
}

class _NetworkImageWithShimmer extends StatelessWidget {
  final String url;
  const _NetworkImageWithShimmer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade300,
          child: Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          ),
        );
      },
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
    );
  }
}
