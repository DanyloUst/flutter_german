import 'package:flutter_german/scraper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_german/api_service.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrapeDefinition returns definitions for a known word', (
    tester,
  ) async {
    final result = await ApiService.scrapeDefinition('run', 'verb');

    expect(result, isNotEmpty);
    for (final def in result) {
      expect(def, isNotEmpty);
    }

    print(result);
  });

  testWidgets('translateShitty2 translates a simple German word', (
    tester,
  ) async {
    final result = await ApiService.translateShitty('Haus', src: 'de', dst: 'en');

    expect(result, isNotEmpty);
    print(result); // should read "house" or close to it
  });
}
