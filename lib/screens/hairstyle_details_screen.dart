// lib/screens/hairstyle_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../classifiers/hairstyle_model.dart';

class HairstyleDetailsScreen extends StatefulWidget {
  final Hairstyle hairstyle;
  const HairstyleDetailsScreen({super.key, required this.hairstyle});

  @override
  State<HairstyleDetailsScreen> createState() => _HairstyleDetailsScreenState();
}

class _HairstyleDetailsScreenState extends State<HairstyleDetailsScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.hairstyle.isFavorite;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Image
                Image.network(
                  hairstyle.imageUrl,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const SizedBox(
                        height: 260,
                        child: Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                ),
                // Heart and Share buttons
                Positioned(
                  top: 16,
                  right: 60,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                          hairstyle.isFavorite = isFavorite;
                        });
                      },
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
                      onPressed: () {},
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
                  // Title
                  Text(
                    hairstyle.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tags (gender, length, type)
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildTag(hairstyle.gender),
                      _buildTag(hairstyle.length),
                      if (hairstyle.tags.contains('Straight'))
                        _buildTag('Straight'),
                      if (hairstyle.tags.contains('Wavy')) _buildTag('Wavy'),
                      if (hairstyle.isTrending)
                        _buildTag('Trending', color: Colors.pinkAccent),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    "A timeless bob cut that frames the face beautifully. Perfect for oval and round face shapes.",
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
                    children: [
                      _buildTag("Oval"),
                      _buildTag("Round"),
                      _buildTag("Heart"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Popularity
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
                    percent: hairstyle.popularity ?? 0.92,
                    progressColor: Colors.pinkAccent,
                    backgroundColor: Colors.grey[300],
                    barRadius: const Radius.circular(16),
                    animation: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${((hairstyle.popularity ?? 0.92) * 100).toInt()}%",
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
                      onPressed: () {
                        // TODO: TryOnScreen removed. Navigation removed or replace with another screen.
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5F6D), Color(0xFF8456EC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Try On This Hairstyle",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
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
