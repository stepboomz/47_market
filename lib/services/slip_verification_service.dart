import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class SlipVerificationService {
  static const String baseUrl = 'https://developer.easyslip.com/api/v1';
  static const String apiKey = '4cb697ad-579a-491e-9052-ff61a347f78b';

  static Future<Map<String, dynamic>?> verifySlip(
    XFile imageFile, {
    required Uint8List imageBytes,
    bool checkDuplicate = false,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verify'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $apiKey';

      // Add file using bytes (works for both web and mobile)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageFile.name,
        ),
      );

      // Add checkDuplicate if needed
      if (checkDuplicate) {
        request.fields['checkDuplicate'] = 'true';
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Parse response body
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing response: $e');
        print('Response body: ${response.body}');
        return null;
      }
      
      // API returns 200 for success, 400 for duplicate slip (but still includes data)
      if (response.statusCode == 200) {
        return jsonData;
      } else if (response.statusCode == 400) {
        // Check if it's a duplicate slip error
        final message = jsonData['message']?.toString();
        if (message == 'duplicate_slip' && jsonData['data'] != null) {
          // Return the data with a flag indicating it's a duplicate
          return {
            'status': 400,
            'message': 'duplicate_slip',
            'data': jsonData['data'],
            'isDuplicate': true,
          };
        }
        // Other 400 errors
        print('Error verifying slip: ${response.statusCode}');
        print('Response: ${response.body}');
        return {
          'status': 400,
          'message': message ?? 'Unknown error',
          'error': true,
        };
      } else {
        print('Error verifying slip: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception verifying slip: $e');
      return null;
    }
  }
}

