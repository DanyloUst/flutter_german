import 'package:flutter_german/models/word_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_german/models/api_exception.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<WordResponse> getWord(String word) async {
    final uri = Uri.http('10.0.2.2:8000', '/word', {'word': word});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get word');
    }

    final data = jsonDecode(response.body);

    return WordResponse.fromJson(data);
  }

  static Future<List<String>> getDefinition(
    String word,
    String wordType,
  ) async {
    final uri = Uri.http('10.0.2.2:8000', '/definition', {
      'word': word,
      'word_type': wordType,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get word');
    }

    final data = jsonDecode(response.body);

    return List<String>.from(data);
  }

  static Future<String> translateSentence(String sentence) async {
    final uri = Uri.http('10.0.2.2:8000', '/translate-sentence');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sentence': sentence}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to translate sentence');
    }

    return jsonDecode(response.body);
  }
}
