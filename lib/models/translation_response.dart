class TranslationResponse {
  final String word;
  final String translation;

  TranslationResponse({required this.word, required this.translation});

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      word: json['word'],
      translation: json['translation'],
    );
  }
}
