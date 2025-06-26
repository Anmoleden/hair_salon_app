// lib/models/hairstyle_model.dart
class Hairstyle {
  final String imageUrl;
  final String title;
  final String gender;
  final String length;
  final bool isTrending;
  bool isFavorite;
  final List<String> tags;
  final String description;
  final String? faceShape;    // New optional
  final double? popularity;   // New optional (0.0 to 1.0)
  final DateTime? triedOn;
  Hairstyle({
    required this.imageUrl,
    required this.title,
    required this.gender,
    required this.length,
    required this.isTrending,
    this.isFavorite = false,
    this.tags = const [],
    this.description = '',
    this.faceShape,
    this.popularity,
    this.triedOn, 
  });
}
