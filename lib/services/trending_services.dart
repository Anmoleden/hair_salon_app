// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/hairstyle_model.dart';


// class ApiService {
//   // Replace with your actual backend URL
//   static const String _baseUrl = 'http://192.168.1.65:8080/api/v1';

//   /// Fetches trending hairstyles from the backend
//   static Future<List<Hairstyle>> fetchTrendingHairstyles() async {
//     final url = Uri.parse('$_baseUrl/hairstyles/trending');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonList = json.decode(response.body);
//       return jsonList.map((json) => Hairstyle.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to fetch trending hairstyles');
//     }
//   }
// }

import '../config/api_config.dart';
import '../classifiers/hairstyle_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<Hairstyle>> fetchTrendingHairstyles() async {
    final uri = ApiConfig.getTrendingHairstylesUri();
    print('Fetching trending hairstyles from: $uri');
    
    final response = await http.get(uri);
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('Parsed ${jsonList.length} hairstyles from JSON');
      return jsonList.map((json) => Hairstyle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch trending hairstyles: ${response.statusCode} - ${response.body}');
    }
  }
}

