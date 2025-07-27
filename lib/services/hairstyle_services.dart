import 'dart:convert';
import 'package:hair_salon/classifiers/hairstyle_model.dart';
import 'package:http/http.dart' as http;

Future<List<Hairstyle>> getRecommendedHairstyles(String faceShape, String gender) async {
  final url = Uri.parse('http://192.168.1.65:8080/hairstyles/recommend?faceShape=$faceShape&gender=$gender');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Hairstyle.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load recommended hairstyles');
  }
}
