class WordResponse {
  final String word;
  final String translations;
  final String germanSentence;
  final String englishSentence;

  WordResponse({
    required this.word,
    required this.translations,
    required this.germanSentence,
    required this.englishSentence,
  });

  factory WordResponse.fromJson(Map<String, dynamic> json) {
    return WordResponse(
      word: json['word'],
      translations: json['translations'],
      germanSentence: json['german_sentence'],
      englishSentence: json['english_sentence'],
    );
  }
}
