import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.arbeitnow.com/api/job-board-api';

  /// Fetches jobs from the API.
  /// Supports pagination through the [page] parameter.
  Future<List<JobModel>> fetchJobs({int page = 1}) async {
    final Uri url = Uri.parse('$_baseUrl?page=$page');

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timed out. Please check your connection and try again.');
        },
      );

      if (response.statusCode == 200) {
        // Decode JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> jobsJson = responseData['data'];
          return jobsJson.map((json) => JobModel.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format from the server.');
        }
      } else {
        throw Exception('Server returned an error: ${response.statusCode} (${response.reasonPhrase})');
      }
    } catch (e) {
      // Re-throw exception with user-friendly text if needed
      if (e is http.ClientException) {
        throw Exception('Network error occurred. Please verify your internet connection.');
      }
      rethrow;
    }
  }
}
