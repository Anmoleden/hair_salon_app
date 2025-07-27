// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/api_config.dart';
// import '../models/hairstyle_model.dart';

// class FavoriteService {
  
//   static Future<List<Hairstyle>> fetchFavorites(String userId) async {
//     final response = await http.get(ApiConfig.getFavoritesUri(userId));

//     print('Status: ${response.statusCode}');
//     print('Body: ${response.body}');

//     if (response.statusCode == 200) {
//       // final decoded = jsonDecode(response.body);
//       final Map<String, dynamic> decoded = jsonDecode(response.body);
//       final List<dynamic> data = decoded['favorites'];

//       if (data == null) {
//       print('No favorites key found in JSON');
//       return [];
//     }

//     if (data.isEmpty) {
//       print('Favorites list is empty');
//       return [];
//     }

//       return data.map((fav) {
//         final hairstyleJson = fav['hairstyle']; // 👈 full hairstyle
//         return Hairstyle.fromJson(hairstyleJson)..isFavorite = true;
//       }).toList();
//     } else {
//       throw Exception('Failed to fetch favorites');
//     }
//   }

//   // Add a hairstyle to favorites
//   static Future<void> addFavorite(String userId, String hairstyleId) async {
//     final response = await http.post(
//       ApiConfig.postFavoriteUri(userId),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'hairstyleId': hairstyleId}),
//     );

//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');

//     if (response.statusCode != 201) {
//       throw Exception('Failed to add favorite');
//     }
//   }

//   // Fetch a single hairstyle by ID
//   static Future<Hairstyle> fetchHairstyleById(String hairstyleId) async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/hairstyles/$hairstyleId');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       return Hairstyle.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to load hairstyle');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../classifiers/hairstyle_model.dart';

class FavoriteService {

  static Future<List<Hairstyle>> fetchFavorites(String userId) async {
    final response = await http.get(ApiConfig.getFavoritesUri(userId));

    print('Favorite API response status: ${response.statusCode}');
    print('Favorite API response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['favorites'];

      print('Favorites array length: ${data.length}');

      return data.map((fav) {
        final hairstyleJson = fav['hairstyle']; // full hairstyle json
        print('Favorite Hairstyle name: ${hairstyleJson['hairstyleName']}');
        return Hairstyle.fromJson(hairstyleJson)..isFavorite = true;
      }).toList();
    } else {
      throw Exception('Failed to fetch favorites');
    }
  }

  static Future<void> addFavorite(String userId, String hairstyleId) async {
    final response = await http.post(
      ApiConfig.postFavoriteUri(userId),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hairstyleId': hairstyleId}),
    );

    print('Add Favorite Status Code: ${response.statusCode}');
    print('Add Favorite Response Body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add favorite');
    }
  }

  static Future<Hairstyle> fetchHairstyleById(String hairstyleId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/hairstyles/$hairstyleId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Hairstyle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load hairstyle');
    }
  }
}
