import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../classifiers/glasses_model.dart';
import 'try_on_glasses.dart';

class GlassesRecommendationPage extends StatefulWidget {
  final File capturedImage;
  final String faceShape;
  final bool isMale;
  final String gender;

  const GlassesRecommendationPage({
    super.key,
    required this.capturedImage,
    required this.faceShape,
    required this.isMale,
    required this.gender,
  });

  @override
  State<GlassesRecommendationPage> createState() =>
      _GlassesRecommendationPageState();
}

class _GlassesRecommendationPageState extends State<GlassesRecommendationPage> {
  List<Glasses> recommendedGlasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendedGlasses();
  }

  Future<void> fetchRecommendedGlasses() async {
    final gender = widget.isMale ? "Male" : "Female";
    final uri = ApiConfig.getRecommendGlassesUri(widget.faceShape, gender);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Glasses> glassesList =
            jsonData.map((item) => Glasses.fromJson(item)).toList();

        setState(() {
          recommendedGlasses = glassesList;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch glasses.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Recommended for ${widget.faceShape} Face"),
        backgroundColor: Colors.teal,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : recommendedGlasses.isEmpty
              ? const Center(child: Text("No recommended glasses found."))
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: recommendedGlasses.length,
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
                                capturedImage: widget.capturedImage,
                                glassesImageUrl: imageUrl,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
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
    );
  }
}
