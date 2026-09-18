import 'dart:async';
import 'dart:io';
import 'package:flutter_german/models/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

// verify=False in Python disables SSL certificate verification.
// Dart's plain http.Client doesn't support this directly, so we build
// a custom client backed by dart:io's HttpClient with cert checks disabled.
// WARNING: this is insecure (accepts any cert, including MITM'd ones) —
// only use it against the specific hosts you already trust/expect here,
// same caveat as in the original Python.
final http.Client _insecureClient = IOClient(
  HttpClient()..badCertificateCallback = (cert, host, port) => true,
);

String urlFriendly(String word) {
  return word.replaceAll('ß', 's5');
}

String cleanWord(String word) {
  word = word.replaceAll('(', '').replaceAll(')', '');
  word = word.replaceAll(
    RegExp(r'[\u2070\u00B9\u00B2\u00B3\u2074-\u2079]+'),
    '',
  );
  return word.trim();
}

// ---------- sibling/text helpers ----------

String? findPreviousTextSibling(Element el) {
  final parent = el.parentNode;
  if (parent == null) return null;

  final siblings = parent.nodes;
  final index = siblings.indexOf(el);
  if (index <= 0) return null;

  for (var i = index - 1; i >= 0; i--) {
    final node = siblings[i];
    if (node is Text) {
      final text = node.text?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
  }
  return null;
}

Element? findByExactText(Document doc, String selector, String text) {
  for (final el in doc.querySelectorAll(selector)) {
    if (el.text.trim() == text) return el;
  }
  return null;
}

Element? findTdByTrimmedText(Element scope, String text) {
  for (final td in scope.querySelectorAll('td')) {
    if (td.text.trim() == text) return td;
  }
  return null;
}

bool _infoParagraphEndsWith(Document soup, String suffix) {
  final infoP = soup.querySelector('p.rInf');
  if (infoP == null) return false;
  return infoP.text.trim().toLowerCase().endsWith(suffix.toLowerCase());
}

// ---------- scrape_noun / scrape_adjective / scrape_verb ----------

Map<String, dynamic> scrapeNoun(Document soup, String word) {
  final articleSection = soup.querySelector('span.vGrnd');
  final wordElement = articleSection?.querySelector('b');
  final article = wordElement != null
      ? (findPreviousTextSibling(wordElement) ?? 'Article not found')
      : 'Article not found';

  final pluralHeading = findByExactText(soup, 'h2', 'Plural');
  final pluralSection = pluralHeading?.parent;

  final pluralForms = <String>{};
  if (pluralSection != null) {
    for (final row in pluralSection.querySelectorAll('tr')) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        pluralForms.add(cleanWord(cells[1].text.trim()));
      }
    }
  }

  return {
    'article': article,
    'plural': pluralForms.isEmpty ? ['Plural not found'] : pluralForms.toList(),
  };
}

Map<String, dynamic> scrapeAdjective(Document soup, String word) {
  final comparativeHeader = findByExactText(soup, 'span', 'comparative');
  final comparativeTable = comparativeHeader?.parent?.parent;

  final comparative = comparativeTable != null
      ? comparativeTable.querySelectorAll('b').map((b) => b.text.trim()).join()
      : '';
  final comparativeResult = comparative.isEmpty
      ? 'Comparative not found'
      : comparative;

  final superlativeHeader = findByExactText(soup, 'span', 'superlative');
  final superlativeTable = superlativeHeader?.parent?.parent;

  final superlative = superlativeTable != null
      ? superlativeTable.querySelectorAll('b').map((b) => b.text.trim()).join()
      : '';
  final superlativeResult = superlative.isEmpty
      ? 'Superlative not found'
      : superlative;

  return {'comparative': comparativeResult, 'superlative': superlativeResult};
}

Map<String, dynamic> scrapeVerb(Document soup, String word) {
  // Infinitive
  final infinitiveHeading = soup
      .querySelectorAll('h2.wG')
      .where((h) => h.text.trim() == 'Infinitive')
      .firstOrNull;
  final infinitiveTable = infinitiveHeading?.parent;
  final infinitiveRaw = infinitiveTable?.querySelector('tr');
  final infinitive = infinitiveRaw != null
      ? cleanWord(infinitiveRaw.text.trim())
      : 'Infinitive not found';

  // Präteritum (Imperfect)
  final prateritumHeading = findByExactText(soup, 'h3', 'Imperfect');
  final prateritumTable = prateritumHeading?.parent;
  final prateritumRaw = prateritumTable != null
      ? findTdByTrimmedText(prateritumTable, 'er')
      : null;
  final prateritum = prateritumRaw?.parent != null
      ? cleanWord(prateritumRaw!.parent!.text.trim())
      : 'Imperfect not found';

  // Perfect
  final perfectHeading = findByExactText(soup, 'h3', 'Perfect');
  final perfectTable = perfectHeading?.parent;
  final perfectRaw = perfectTable
      ?.querySelectorAll('td')
      .where((td) => td.text == ' er')
      .firstOrNull;
  final perfect = perfectRaw?.parent != null
      ? cleanWord(perfectRaw!.parent!.text.trim())
      : 'Perfect not found';

  return {
    'infinitive': infinitive,
    'prateritum': prateritum,
    'perfect': perfect,
  };
}

// ---------- scrape_info ----------

Map<String, dynamic>? scrapeInfo(String word, Document soup, dynamic info) {
  // `info` mirrors Python's dynamic typing: sometimes a specific <div>,
  // sometimes the whole `soup` document itself (the woerter.net fallback).
  // Both Element and Document support querySelector/querySelectorAll in
  // package:html, so we type it dynamic and call through duck-typing.

  final translationsEl = soup.querySelector('span[lang="en"]');
  final List<String> translationList;
  if (translationsEl == null) {
    translationList = ['No translation found.'];
  } else {
    translationList = translationsEl.text
        .trim()
        .split(',')
        .map((t) => t.trim())
        .toList();
  }

  String germanSentence = 'Sentence not found.';
  String englishSentence = 'Sentence not found.';

  final sentenceSoup = info.querySelector('ul.rLst.rLstGt') as Element?;

  if (sentenceSoup != null) {
    final sentenceRows = sentenceSoup.querySelectorAll('li');
    if (sentenceRows.isNotEmpty) {
      final sentence = sentenceRows[0];
      final br = sentence.querySelector('br');

      if (br != null) {
        final siblings = br.parentNode!.nodes;
        final brIndex = siblings.indexOf(br);
        final beforeBr = siblings.sublist(0, brIndex);
        final previousSiblings = beforeBr.reversed;

        final germanParts = <String>[];
        for (final node in previousSiblings) {
          if (node is Element && node.localName == 'a') continue;
          germanParts.add(node.text?.trim() ?? '');
        }

        germanSentence = germanParts.reversed.join(' ').trim();
        for (final punctuation in ['.', ',', '!', '?', ':', ';']) {
          germanSentence = germanSentence.replaceAll(
            ' $punctuation',
            punctuation,
          );
        }

        final englishImage = sentence.querySelector('img[alt="English"]');
        if (englishImage?.parent != null) {
          englishSentence = englishImage!.parent!.text.trim();
        }
      }
    }
  }

  final nounHeader = soup.querySelector('span[title="noun"]');
  final adjectiveHeader = soup.querySelector('span[title="adjective"]');
  final adverbHeader = soup.querySelector('span[title="adverb"]');
  final prepositionHeader = soup.querySelector('span[title="preposition"]');
  final conjunctionHeader = soup.querySelector('span[title="conjunction"]');
  final particleHeader = soup.querySelector('span[title="particle"]');
  final isSein = _infoParagraphEndsWith(soup, 'sein');
  final isHaben = _infoParagraphEndsWith(soup, 'haben');

  final commonData = {
    'word': word,
    'translations': translationList,
    'german_sentence': germanSentence,
    'english_sentence': englishSentence,
  };

  //Currently returns nothign for articles
  if (nounHeader != null) {
    final nounInfo = scrapeNoun(soup, word);
    return {...commonData, ...nounInfo, 'type': 'noun'};
  } else if (adjectiveHeader != null) {
    return {...commonData, ...scrapeAdjective(soup, word), 'type': 'adjective'};
  } else if (isSein) {
    return {...commonData, ...scrapeVerb(soup, word), 'type': 'sein'};
  } else if (isHaben) {
    return {...commonData, ...scrapeVerb(soup, word), 'type': 'haben'};
  } else if (adverbHeader != null) {
    return {...commonData, 'type': 'adverb'};
  } else if (prepositionHeader != null) {
    return {...commonData, 'type': 'preposition'};
  } else if (conjunctionHeader != null) {
    return {...commonData, 'type': 'conjunction'};
  } else if (particleHeader != null) {
    return {...commonData, 'type': 'particle'};
  } else {
    return null;
  }
}

// ---------- scrape_word (main entry point) ----------

Future<List<Map<String, dynamic>>> scrapeWord(String word) async {
  final urlWord = urlFriendly(word); // used only for building request URLs
  final resultList = <Map<String, dynamic>>[];
  final url = 'https://www.verbformen.com/?w=$urlWord';

  var response = await http
      .get(Uri.parse(url))
      .timeout(const Duration(seconds: 15));

  print('REQUEST: $url');
  print('STATUS: ${response.statusCode}');

  if (response.statusCode == 429) {
    print('Rate limited: $url');
    print('Retry-After: ${response.headers['retry-after']}');
    throw ApiException('Too many requests, rate limit reached. Try again later');
  }

  if (response.statusCode != 200) {
    print('Request failed (${response.statusCode}): $url');
    throw ApiException('Request failed.');
  }

  await Future.delayed(const Duration(seconds: 3));

  var soup = html_parser.parse(response.body);

  dynamic info = soup.querySelector('div.rInfo');

  if (info == null) {
    final searchResult = soup.querySelector('.bTrf.rClear');
    if (searchResult == null) {
      throw ApiException('No word matches $word. Check the spelling and try again.');
    } else {
      final fallbackUrl = 'https://www.woerter.net/?w=$urlWord';
      // verify=False in Python -> use the insecure client here
      response = await _insecureClient
          .get(Uri.parse(fallbackUrl))
          .timeout(const Duration(seconds: 15));
      soup = html_parser.parse(response.body);
      info = soup; // Python assigns info = soup in this branch
    }
  }

  final result = scrapeInfo(word, soup, info);
  if (result != null) {
    resultList.add(result);
  }

  final wordTypes = <String>[];
  final typesAll = soup.querySelectorAll('.rKnpf.rNoSelect.rLinks');
  for (final wordTypeEl in typesAll) {
    final selected = wordTypeEl.querySelector('img[src="/selected.svg"]');
    if (selected == null) {
      final typeTextEl = wordTypeEl.querySelector('.rKln.rInf');
      final typeText = typeTextEl?.text.trim();
      if (typeText != null) wordTypes.add(typeText);
    }
  }

  if (wordTypes.isEmpty) {
    return resultList;
  }

  
  String getInfinitive(){
    final infinitiveHeading = soup
      .querySelectorAll('h2.wG')
      .where((h) => h.text.trim() == 'Infinitive')
      .firstOrNull;
  final infinitiveTable = infinitiveHeading?.parent;
  final infinitiveRaw = infinitiveTable?.querySelector('tr');
  final infinitive = infinitiveRaw != null
      ? cleanWord(infinitiveRaw.text.trim())
      : 'Infinitive not found';

  return infinitive;
  }

  for (final wordType in wordTypes) {
    String typeUrl;

    if (wordType == 'sein') {
      final urlInfinitive = getInfinitive();
      typeUrl = 'https://www.verbformen.com/conjugation/${urlInfinitive}_ist.htm';
    } else if (wordType == 'haben') {
      final urlInfinitive = getInfinitive();
      typeUrl = 'https://www.verbformen.com/conjugation/${urlInfinitive}_hat.htm';
    } else if (wordType == 'noun' ||
        wordType == 'neutral' ||
        wordType == 'feminine' ||
        wordType == 'masculine') {
      typeUrl = 'https://www.verbformen.com/declension/nouns/$urlWord.htm';
    } else if (wordType == 'positive') {
      typeUrl = 'https://www.verbformen.com/declension/adjectives/$urlWord.htm';
    } else if (wordType == 'comparative' || wordType == 'superlative') {
      continue;
    } else {
      typeUrl = 'https://www.woerter.net/${wordType}s/$urlWord.htm';
    }

    print('\n--- REQUEST $wordType ---');
    print(typeUrl);

    await Future.delayed(const Duration(seconds: 3));

    // verify=False for all of these follow-up requests too
    final typeResponse = await _insecureClient
        .get(Uri.parse(typeUrl))
        .timeout(const Duration(seconds: 15));

    print('STATUS: ${typeResponse.statusCode}');

    if (typeResponse.statusCode == 429) {
      print('Rate limited: $typeUrl');
      continue;
    }

    if (typeResponse.statusCode != 200) {
      print('Request failed (${typeResponse.statusCode}): $typeUrl');
      continue;
    }

    final typeSoup = html_parser.parse(typeResponse.body);
    print('Parsed typeSoup for $wordType');

    dynamic typeInfo;

    if (typeUrl.contains('verbformen.com')) {
      typeInfo = typeSoup.querySelector('div.rInfo');
    } else if (typeUrl.contains('woerter.net')) {
      typeInfo = typeSoup;
    }
    print('typeInfo resolved for $wordType: ${typeInfo != null}');

    final typeResult = scrapeInfo(word, typeSoup, typeInfo);
    print('scrapeInfo completed for $wordType: ${typeResult != null}');
    if (typeResult != null) {
      resultList.add(typeResult);
    }
  }
  print('Finished loop, returning ${resultList.length} results');
  return resultList;
}
