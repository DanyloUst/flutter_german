import 'package:flutter_german/models/word_response.dart';
import 'package:flutter_german/scraper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
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

  static Future<WordResponse> getWordDart(String word) async {
    final data = await scrapeWord(word);

    if (data.isEmpty) {
      throw Exception('Failed to get word');
    }

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

  static Future<String> translateShitty(String sentence) async {
    final uri = Uri.http('10.0.2.2:8000', '/translate-shitty');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sentence': sentence}),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to translate sentence');
    }

    return jsonDecode(response.body);
  }

  static Future<String> translateShitty2(
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

/*
=========================================================================
ORIGINAL PYTHON BACKEND (for reference during migration — remove once
the Dart port is fully verified and the FastAPI backend is decommissioned)
=========================================================================

def clean_word(word):
    # Remove parentheses but keep their contents
    word = word.replace("(", "").replace(")", "")

    # Remove superscript numbers
    word = re.sub(r"[⁰¹²³⁴⁵⁶⁷⁸⁹]+", "", word)

    return word.strip()


def scrape_word(word):
    url = f"https://www.verbformen.com/?w={word}"

    response = requests.get(url)

    soup = BeautifulSoup(response.text, "html.parser")

    translations = soup.find("span", lang="en")

    translation_string = translations.get_text(strip=True).split(',')

    translation_list = [
        translation.strip()
        for translation in translations.get_text(strip=True).split(",")
    ]

    info = soup.find("div", class_="rInfo")

    sentence_soup = info.find(
        "ul",
        class_="rLst rLstGt"
    )
    sentence_rows = sentence_soup.find_all("li")
    sentence = sentence_rows[0]

    br = sentence.find("br")

    german_parts = []

    for item in br.previous_siblings:
        if getattr(item, "name", None) == "a":
            continue

        german_parts.append(item.get_text().strip())

    german_sentence = " ".join(reversed(german_parts)).strip()

    for punctuation in [".", ",", "!", "?", ":", ";"]:
        german_sentence = german_sentence.replace(f" {punctuation}", punctuation)

    english_image = sentence.find("img", alt="English")
    english_sentence = english_image.parent.get_text(strip=True)

    noun_header = soup.find("span", title="noun")
    adjective_header = soup.find("span", title="adjective")
    verb_header = soup.find(
        "h1",
        string=lambda text: text and "Conjugation of German verb" in text
    )

    common_data = {"word": word, "translations": translation_list,
                   "german_sentence": german_sentence,
                   "english_sentence": english_sentence}

    if noun_header:
        word_type = "noun"
        noun_info = scrape_noun(soup, word)
        return common_data | noun_info | {"type": word_type}

    elif adjective_header:
        word_type = "adjective"
        adjective_info = scrape_adjective(soup, word)
        return common_data | adjective_info | {"type": word_type}

    elif verb_header:
        word_type = "verb"
        verb_info = scrape_verb(soup, word)
        return common_data | verb_info | {"type": word_type}

    else:
        return {}


def scrape_noun(soup, word):
    article_section = soup.find("span", class_="vGrnd")
    word_element = article_section.find("b")

    article = word_element.find_previous_sibling(string=True).strip()

    plural_heading = soup.find(
        "h2",
        string="Plural"
    )

    plural_section = plural_heading.parent

    rows = plural_section.find_all("tr")

    plural_forms = set()

    for row in rows:
        cells = row.find_all("td")

        if len(cells) >= 2:
            form = cells[1].get_text(strip=True)
            plural_forms.add(clean_word(form))

    return {"article": article, "plural": plural_forms}


def scrape_adjective(soup, word):
    comparative_header = soup.find("span", string="comparative")
    comparative_table = comparative_header.parent.parent

    comparative_parts = comparative_table.find_all("b")
    comparative = ""
    for part in comparative_parts:
        comparative += part.get_text().strip()

    superlative_header = soup.find("span", string="superlative")
    superlative_table = superlative_header.parent.parent
    superlative_parts = superlative_table.find_all("b")
    superlative = ""
    for part in superlative_parts:
        superlative += part.get_text().strip()

    return {"comparative": comparative, "superlative": superlative}


def scrape_verb(soup, word):
    infinitive_heading = soup.find(
        "h2",
        class_="wG",
        string="Infinitive"
    )
    infinitive_table = infinitive_heading.parent
    infinitive_raw = infinitive_table.find("tr")
    infinitive = clean_word(infinitive_raw.get_text().strip())

    prateritum_heading = soup.find(
        "h3",
        string="Imperfect"
    )
    prateritum_table = prateritum_heading.parent
    prateritum_raw = prateritum_table.find(
        "td",
        string=lambda text: text and text.strip() == "er"
    )
    prateritum = clean_word(prateritum_raw.parent.get_text().strip())

    perfect_heading = soup.find(
        "h3",
        string="Perfect"
    )
    perfect_table = perfect_heading.parent
    perfect_raw = perfect_table.find("td", string=" er")
    perfect = clean_word(perfect_raw.parent.get_text().strip())

    return {"infinitive": infinitive, "prateritum": prateritum, "perfect": perfect}


def scrape_definition(word, word_type):
    url = f"https://www.dictionary.com/browse/{word}"

    response = requests.get(url)

    soup = BeautifulSoup(response.text, "html.parser")

    headers_of_type = soup.find_all(
        "h2",
        string=lambda text: text and word_type in text
    )
    definitions = []
    for header in headers_of_type:
        parent = header.parent.parent
        list_definitions = parent.find_all("li", class_="item-definition")
        for definition in list_definitions:
            em = definition.find("em")
            if em:
                em.decompose()

            definitions.append(definition.get_text(" ", strip=True))
    return definitions


def translate_shitty2(text2, src="de", dst="en"):
    url = "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute"

    f_req = json.dumps([[["MkEWBc", json.dumps([[text2, src, dst, 1, None, 2], []]), None, "generic"]]])

    payload = {
        "f.req": f_req,
        "at": "ABlc7lVRnd3zxUhDtIJEa07roK-c:1788801955550",
    }

    headers = {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
    }

    res = requests.post(url, data=payload, headers=headers)
    res.raise_for_status()

    return json.loads(json.loads(res.text[6:])[0][2])[1][0][0][5][0][0]

=========================================================================
*/