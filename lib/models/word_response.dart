import 'dart:convert';

class WordResponse {
  final String word;
  final List<String> translations;
  final String germanSentence;
  final String englishSentence;
  final String type;
  final NounData? nounData;
  final VerbData? verbData;
  final AdjectiveData? adjectiveData;

  WordResponse({
    required this.word,
    required this.translations,
    required this.germanSentence,
    required this.englishSentence,
    required this.type,
    this.nounData,
    this.verbData,
    this.adjectiveData
  });

  factory WordResponse.fromJson(Map<String, dynamic> json) {
    return WordResponse(
      word: json['word'],
      translations: (json['translations'] as List).map((item) => item.toString()).toList(),
      germanSentence: json['german_sentence'],
      englishSentence: json['english_sentence'],
      type: json['type'],
      nounData: json['type'] == 'noun' ? NounData.fromJson(json) : null,
      verbData: json['type'] == 'sein' || json['type'] == 'haben' ? VerbData.fromJson(json) : null,
      adjectiveData: json['type'] == 'adjective' ? AdjectiveData.fromJson(json) : null,
    );
  }
}

class NounData {
  final String article;
  final List<String> plural;

  NounData({required this.article, required this.plural});
  factory NounData.fromJson(Map<String, dynamic> json) {
    return NounData(
      article: json['article'],
      plural: (json['plural'] as List).map((item) => item.toString()).toList(),
    );
  }
}

class VerbData {
  final String infinitive;
  final String prateritum;
  final String perfect;

  VerbData({
    required this.infinitive,
    required this.prateritum,
    required this.perfect,
  });
  factory VerbData.fromJson(Map<String, dynamic> json) {
    return VerbData(
      infinitive: json['infinitive'],
      prateritum: json['prateritum'],
      perfect: json['perfect'],
    );
  }
}

class AdjectiveData {
  final String comparative;
  final String superlative;

  AdjectiveData({required this.comparative, required this.superlative});
  factory AdjectiveData.fromJson(Map<String, dynamic> json) {
    return AdjectiveData(
      comparative: json['comparative'],
      superlative: json['superlative'],
    );
  }
}

class ScrapedData{
  final List<WordResponse> wordResponses;
  final String originalSentence;
  final String? translatedSentence;

  ScrapedData({required this.wordResponses, required this.originalSentence, this.translatedSentence});
}