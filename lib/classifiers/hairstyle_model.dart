class Hairstyle {
  final String id;
  final String hairstyleId;
  final String hairstyleName;
  final String gender;
  final String category;
  final List<String> faceShapes;
  final String imageUrl;
  final String representingImageUrl;
  final int popularity;
  final String description;
  final DateTime? triedOn;
  final List<String> tags;

  bool isTrending;
  bool isFavorite;

  Hairstyle({
    required this.id,
    required this.hairstyleId,
    required this.hairstyleName,
    required this.gender,
    required this.category,
    required this.faceShapes,
    required this.imageUrl,
    required this.representingImageUrl,
    this.isFavorite = false,
    this.isTrending = false,
    required this.popularity,
    required this.description,
    this.triedOn,
    this.tags = const [],
  });

  factory Hairstyle.fromJson(Map<String, dynamic> json) {
    return Hairstyle(
      //id: json['_id'] ?? '',
       id: json['_id'] is Map<String, dynamic> ? json['_id']['\$oid'] : json['_id'] ?? '',
      hairstyleId: json['hairstyleId'],
      hairstyleName: json['hairstyleName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      representingImageUrl: json['representingImageUrl'] ?? '',
      gender: json['gender'] ?? '',
      category: json['category'] ?? '',
      faceShapes: List<String>.from(json['faceShapes'] ?? []),
      popularity: json['popularity'] ?? 0,
      description: json['description'] ?? '',
      triedOn:
          json['triedOn'] != null ? DateTime.tryParse(json['triedOn']) : null,
      isFavorite: json['isFavorite'] ?? false,
      isTrending: json['isTrending'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}
