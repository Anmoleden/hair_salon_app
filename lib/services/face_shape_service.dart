import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FaceShapeService {
  static Future<String?> predictFaceShape(File imageFile) async {
    try {
      final uri = Uri.parse('https://your-api.com/predict-face-shape'); // ⬅️ Replace with your backend endpoint

      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);
        return decoded['faceShape'];
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Prediction failed: $e');
      return null;
    }
  }
}
