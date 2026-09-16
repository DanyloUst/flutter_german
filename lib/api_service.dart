import 'package:flutter_german/models/word_response.dart';
import 'package:flutter_german/scraper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:flutter_german/models/api_exception.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static List<Element> findAllContainingText(
    Document doc,
    String selector,
    String substring,
  ) {
    return doc
        .querySelectorAll(selector)
        .where((el) => el.text.contains(substring))
        .toList();
  }
  /// Mirrors bs4's get_text(separator, strip=True): joins all descendant
  /// text nodes with [separator], stripping each piece and dropping empties.
  static String getTextWithSeparator(Element el, String separator) {
    final pieces = <String>[];

    void visit(Node node) {
      if (node is Text) {
        final trimmed = node.text?.trim() ?? '';
        if (trimmed.isNotEmpty) pieces.add(trimmed);
      } else if (node is Element) {
        for (final child in node.nodes) {
          visit(child);
        }
      }
    }

    for (final child in el.nodes) {
      visit(child);
    }

    return pieces.join(separator);
  }

    static Future<WordResponse> getWordDart(String word) async {
    final data = await scrapeWord(word);

    if (data.isEmpty) {
      throw Exception('Failed to get word');
    }

    return WordResponse.fromJson(data);
  }

  static Future<List<String>> scrapeDefinition(
    String word,
    String wordType,
  ) async {
    final url = Uri.parse('https://www.dictionary.com/browse/$word');
    final response = await http.get(url);

    final document = html_parser.parse(response.body);

    final headersOfType = findAllContainingText(document, 'h2', wordType);

    final definitions = <String>[];

    for (final header in headersOfType) {
      // header.parent.parent
      final parent = header.parent?.parent;
      if (parent == null) continue;

      final listDefinitions = parent.querySelectorAll('li.item-definition');

      for (final definition in listDefinitions) {
        // em.decompose() -- remove the <em> element from the tree entirely
        final em = definition.querySelector('em');
        em?.remove();

        definitions.add(getTextWithSeparator(definition, ' '));
      }
    }

    return definitions;
  }

  static Future<String> translateShitty(
    String text2, {
    String src = 'de',
    String dst = 'en',
  }) async {
    final url = Uri.parse(
      'https://translate.google.com/_/TranslateWebserverUi/data/batchexecute',
    );

    final fReq = jsonEncode([
      [
        [
          'MkEWBc',
          jsonEncode([
            [text2, src, dst, 1, null, 2],
            [],
          ]),
          null,
          'generic',
        ],
      ],
    ]);

    // WARNING: this "at" token is a hardcoded, likely session-scoped/expiring
    // anti-abuse token copied from the Python version. This will probably
    // break once it expires — there's no way to "refresh" it without capturing
    // a fresh one from a real browser session hitting translate.google.com.
    final payload = {
      'f.req': fReq,
      'at': 'ABlc7lVRnd3zxUhDtIJEa07roK-c:1788801955550',
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      },
      body: payload, // http package auto-urlencodes a Map<String, String> body
    );

    if (response.statusCode != 200) {
      throw Exception('Translation request failed: ${response.statusCode}');
    }

    // res.text[6:] strips Google's anti-JSON-hijacking prefix ")]}'\n"
    final stripped = response.body.substring(6);

    final outer = jsonDecode(stripped) as List;
    final inner = jsonDecode(outer[0][2] as String) as List;

    return inner[1][0][0][5][0][0] as String;
  }
}