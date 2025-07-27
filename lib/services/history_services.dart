// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/hairstyle_model.dart';
// import '../config/api_config.dart';

// class ApiService {
//   static Future<List<Hairstyle>> fetchHistory(String userId) async {
//     final response = await http.get(ApiConfig.getHistoryUri(userId));

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       return jsonData.map((item) => Hairstyle.fromJson(json['hairstyle'])).toList();
//     } else {
//       throw Exception('Failed to load history');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../classifiers/hairstyle_model.dart';

class HistoryService {

  static Future<List<Hairstyle>> fetchHistory(String userId) async {
    // final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/history/$userId');
    final url = ApiConfig.getHistoryUri(userId);
    final res = await http.get(url);

    if (res.statusCode == 200) {
      //final List data = json.decode(res.body);
      final Map<String, dynamic> responseData = json.decode(res.body);
      final List<dynamic> historyList = responseData['history'];

      // return historyList
      //     .where((item) => item['hairstyle'] != null)
      //     .map((item) => Hairstyle.fromJson(item['hairstyle']))
      //     .toList();
      return historyList.map((item) {
        final hairstyleJson = item['hairstyle'];
        hairstyleJson['triedAt'] = item['triedAt'];
        return Hairstyle.fromJson(hairstyleJson);
      }).toList();
    } else {
      throw Exception('Failed to fetch history');
    }
  }

  static Future<void> clearHistory(String userId) async {
    final url = ApiConfig.getHistoryUri(userId);
    final res = await http.delete(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to clear history');
    }
  }
}
