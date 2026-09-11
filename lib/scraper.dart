import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

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

/// Finds the first element matching [selector] whose own text
/// equals [text] exactly (bs4's string="...").
Element? findByExactText(Document doc, String selector, String text) {
  for (final el in doc.querySelectorAll(selector)) {
    if (el.text.trim() == text) return el;
  }
  return null;
}

/// Finds the first td whose text equals [text] after trimming,
/// mirroring bs4's string=lambda text: text.strip() == "..."
Element? findTdByTrimmedText(Element scope, String text) {
  for (final td in scope.querySelectorAll('td')) {
    if (td.text.trim() == text) return td;
  }
  return null;
}

// ---------- clean_word ----------

String cleanWord(String word) {
  word = word.replaceAll('(', '').replaceAll(')', '');
  word = word.replaceAll(
    RegExp(r'[\u2070\u00B9\u00B2\u00B3\u2074-\u2079]+'),
    '',
  );
  return word.trim();
}

// ---------- scrape_noun ----------

Map<String, dynamic> scrapeNoun(Document doc, String word) {
  final articleSection = doc.querySelector('span.vGrnd');
  final wordElement = articleSection?.querySelector('b');
  if (wordElement == null) {
    throw StateError('Could not find noun word element for "$word"');
  }

  final article = findPreviousTextSibling(wordElement);
  if (article == null) {
    throw StateError('Could not find article for "$word"');
  }

  final pluralHeading = findByExactText(doc, 'h2', 'Plural');
  final pluralSection = pluralHeading?.parent;
  if (pluralSection == null) {
    throw StateError('Could not find plural section for "$word"');
  }

  final rows = pluralSection.querySelectorAll('tr');
  final pluralForms = <String>{};

  for (final row in rows) {
    final cells = row.querySelectorAll('td');
    if (cells.length >= 2) {
      final form = cells[1].text.trim();
      pluralForms.add(cleanWord(form));
    }
  }

  return {'article': article, 'plural': pluralForms};
}

// ---------- scrape_adjective ----------

Map<String, dynamic> scrapeAdjective(Document doc, String word) {
  final comparativeHeader = findByExactText(doc, 'span', 'comparative');
  final comparativeTable = comparativeHeader?.parent?.parent;
  if (comparativeTable == null) {
    throw StateError('Could not find comparative table for "$word"');
  }
  final comparative = comparativeTable
      .querySelectorAll('b')
      .map((b) => b.text.trim())
      .join();

  final superlativeHeader = findByExactText(doc, 'span', 'superlative');
  final superlativeTable = superlativeHeader?.parent?.parent;
  if (superlativeTable == null) {
    throw StateError('Could not find superlative table for "$word"');
  }
  final superlative = superlativeTable
      .querySelectorAll('b')
      .map((b) => b.text.trim())
      .join();

  return {'comparative': comparative, 'superlative': superlative};
}

// ---------- scrape_verb ----------

Map<String, dynamic> scrapeVerb(Document doc, String word) {
  // Infinitive
  final infinitiveHeading = doc
      .querySelectorAll('h2.wG')
      .where((h) => h.text.trim() == 'Infinitive')
      .firstOrNull;
  final infinitiveTable = infinitiveHeading?.parent;
  final infinitiveRaw = infinitiveTable?.querySelector('tr');
  if (infinitiveRaw == null) {
    throw StateError('Could not find infinitive for "$word"');
  }
  final infinitive = cleanWord(infinitiveRaw.text.trim());

  // Präteritum (Imperfect)
  final prateritumHeading = findByExactText(doc, 'h3', 'Imperfect');
  final prateritumTable = prateritumHeading?.parent;
  if (prateritumTable == null) {
    throw StateError('Could not find imperfect table for "$word"');
  }
  final prateritumRaw = findTdByTrimmedText(prateritumTable, 'er');
  if (prateritumRaw?.parent == null) {
    throw StateError('Could not find imperfect form for "$word"');
  }
  final prateritum = cleanWord(prateritumRaw!.parent!.text.trim());

  // Perfect
  final perfectHeading = findByExactText(doc, 'h3', 'Perfect');
  final perfectTable = perfectHeading?.parent;
  if (perfectTable == null) {
    throw StateError('Could not find perfect table for "$word"');
  }
  // Note: Python used string=" er" (leading space, untrimmed) here,
  // unlike the lambda-trimmed check above — preserved as-is below.
  final perfectRaw = perfectTable
      .querySelectorAll('td')
      .where((td) => td.text == ' er')
      .firstOrNull;
  if (perfectRaw?.parent == null) {
    throw StateError('Could not find perfect form for "$word"');
  }
  final perfect = cleanWord(perfectRaw!.parent!.text.trim());

  return {
    'infinitive': infinitive,
    'prateritum': prateritum,
    'perfect': perfect,
  };
}

Future<Map<String, dynamic>> scrapeWord(String word) async {
  final url = Uri.parse('https://www.verbformen.com/?w=$word');
  final response = await http.get(url);

  final document = html_parser.parse(response.body);
  final translationsEl = document.querySelector('span[lang="en"]');
  if (translationsEl == null) {
    return {};
  }

  final translationList = translationsEl.text
      .trim()
      .split(',')
      .map((t) => t.trim())
      .toList();

  final info = document.querySelector('div.rInfo');
  if (info == null) return {};

  final sentenceList = info.querySelector('ul.rLst.rLstGt');
  if (sentenceList == null) return {};

  final sentenceRows = sentenceList.querySelectorAll('li');
  if (sentenceRows.isEmpty) return {};
  final sentence = sentenceRows[0];

  final br = sentence.querySelector('br');
  if (br == null) return {};

  final siblings = br.parentNode!.nodes;
  final brIndex = siblings.indexOf(br);
  final beforeBr = siblings.sublist(0, brIndex);
  final previousSiblings = beforeBr.reversed;

  final germanParts = <String>[];
  for (final node in previousSiblings) {
    if (node is Element && node.localName == 'a') {
      continue;
    }

    germanParts.add(node.text?.trim() ?? '');
  }

  var germanSentence = germanParts.reversed.join(' ').trim();

  for (final punctuation in ['.', ',', '!', '?', ':', ';']) {
    germanSentence = germanSentence.replaceAll(' $punctuation', punctuation);
  }

  final englishImage = sentence.querySelector('img[alt="English"]');
  if (englishImage?.parent == null) return {};
  final englishSentence = englishImage!.parent!.text.trim();

  final nounHeader = document.querySelector('span[title="noun"]');
  final adjectiveHeader = document.querySelector('span[title="adjective"]');
  final verbHeader = document
      .querySelectorAll('h1')
      .where((h) => h.text.contains('Conjugation of German verb'));

  final commonData = {
    'word': word,
    'translations': translationList,
    'german_sentence': germanSentence,
    'english_sentence': englishSentence,
  };

  if (nounHeader != null) {
    final nounInfo = scrapeNoun(document, word);
    nounInfo['plural'] = (nounInfo['plural'] as Set<String>).toList();
    return {...commonData, ...nounInfo, 'type': 'noun'};
  } else if (adjectiveHeader != null) {
    final adjectiveInfo = scrapeAdjective(document, word);
    return {...commonData, ...adjectiveInfo, 'type': 'adjective'};
  } else if (verbHeader.isNotEmpty) {
    final verbInfo = scrapeVerb(document, word);
    return {...commonData, ...verbInfo, 'type': 'verb'};
  } else {
    return {};
  }
}
