import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  /// Translates text to English using Google Translate API.
  /// Splits long text into chunks to handle length limits.
  static Future<String> translateToEnglish(String text) async {
    if (text.trim().isEmpty) return text;

    // Strip HTML tags
    final plainText = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Chunk text if too long (limit ~4500 chars per request)
    const chunkSize = 4500;
    final chunks = <String>[];
    for (var i = 0; i < plainText.length; i += chunkSize) {
      chunks.add(plainText.substring(
        i,
        i + chunkSize > plainText.length ? plainText.length : i + chunkSize,
      ));
    }

    final translatedChunks = <String>[];
    for (final chunk in chunks) {
      final translated = await _translateChunk(chunk);
      translatedChunks.add(translated);
    }

    return translatedChunks.join(' ');
  }

  static Future<String> _translateChunk(String text) async {
    final url = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=auto&tl=en&dt=t&q=${Uri.encodeComponent(text)}',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Translation timed out'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Response format: [[["translated text","original text",null,null,10],...],...]
        final StringBuffer result = StringBuffer();
        if (data is List && data.isNotEmpty && data[0] is List) {
          for (final segment in data[0]) {
            if (segment is List && segment.isNotEmpty) {
              result.write(segment[0]);
            }
          }
        }
        final translated = result.toString();
        return translated.isNotEmpty ? translated : text;
      }
      return text;
    } catch (e) {
      rethrow;
    }
  }
}
