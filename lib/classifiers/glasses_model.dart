class Glasses {
  final String glassesId;
  final String glassesName;
  final String imageUrl;
  final List<String> faceShapes;
  final String gender;

  Glasses({
    required this.glassesId,
    required this.glassesName,
    required this.imageUrl,
    required this.faceShapes,
    required this.gender,
  });

  factory Glasses.fromJson(Map<String, dynamic> json) {
    return Glasses(
      glassesId: json['_glassesId'] ?? '',
      glassesName: json['glassesName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      faceShapes: List<String>.from(json['faceShapes']),
      gender: json['gender'],
    );
  }
}
