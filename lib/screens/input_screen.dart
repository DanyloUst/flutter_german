import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/models/api_exception.dart';
import 'package:flutter_german/models/word_response.dart';
import 'package:flutter_german/screens/debug_screen.dart';
import 'package:flutter_german/screens/output_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<StatefulWidget> createState() => InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  bool isLoading = false;
  String? errorMessage;
  ScrapedData? scrapedData;
  TextEditingController wordController = TextEditingController();
  TextEditingController sentenceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("German Scrapper"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebugScreen()),
              );
            },
            child: Text('TEST'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a word and a sentence to learn more about the word.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            Text('Word'),
            TextField(
              decoration: InputDecoration(hint: Text('e.g. Haus')),
              controller: wordController,
            ),
            SizedBox(height: 15),
            Text('Sentence'),
            TextField(
              decoration: InputDecoration(
                hint: Text('e.g. Ich gehe nach Hause'),
              ),
              maxLines: 2,
              controller: sentenceController,
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  scrapeData();
                },
                child: !isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Scrape'),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward),
                        ],
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scrapeData() async {
    final word = wordController.text.trim();

    if (word.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final sentence = sentenceController.text;
    if (sentence.isEmpty) {
      return;
    }

    try {
      final result = await ApiService.getWordDart(word);
      final translated = await ApiService.translateShitty(sentence);
      scrapedData = ScrapedData(
        wordResponse: result,
        originalSentence: sentence,
        translatedSentence: translated,
      );
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutputScreen(scrapedData: scrapedData!),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not connect to the server.';
        isLoading = false;
      });
    }
  }
}
