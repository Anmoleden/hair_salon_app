import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class InteractionService {
  static Future<void> addToHistory(String userId, String hairstyleId) async {
    final url = ApiConfig.postAddToHistoryUri(userId);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hairstyleId': hairstyleId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to history');
    }
  }

  static Future<void> incrementPopularity(String hairstyleId) async {
    final url = ApiConfig.getIncrementPopularityUri(hairstyleId);
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to increment popularity');
    }
  }
}
