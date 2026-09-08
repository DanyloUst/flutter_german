import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/app_colors.dart';
import 'package:flutter_german/models/api_exception.dart';
import 'package:flutter_german/models/word_response.dart';
import 'package:flutter_german/screens/input_screen.dart';
import 'package:flutter_german/screens/output_screen.dart';
import 'package:flutter_german/screens/output_screen_outdated.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.primaryText,
            backgroundColor: AppColors.primaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ),
      home: Scaffold(body: Center(child: OutputScreen())),
    );
  }
}

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return InputScreen();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController wordController = TextEditingController();
  TextEditingController sentenceController = TextEditingController();
  String? word;
  List<String>? translation;
  ScrapedData? scrapedData;
  String? errorMessage;
  String? germanSentence;
  String? englishSentence;
  String? germanSentence2;
  String? englishSentence2;
  String? germanSentence3;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: wordController),
            TextField(controller: sentenceController),
            ElevatedButton(
              onPressed: isLoading ? null : translateWord,
              child: Text('test'),
            ),
            ElevatedButton(onPressed: () async {}, child: Text('test DEF')),
            if (isLoading) const CircularProgressIndicator(),

            ElevatedButton(
              onPressed: () async {
                final sentence = sentenceController.text;
                if (sentence.isEmpty) {
                  return;
                }
                final word = wordController.text;
                if (word.isEmpty) {
                  return;
                }
                final blankString = '_' * word.length;
                final noWordSentence = sentence.replaceAll(word, blankString);

                final translated = await ApiService.translateShitty(sentence);
                setState(() {
                  englishSentence2 = translated;
                  germanSentence2 = sentence;
                  germanSentence3 = noWordSentence;
                });
              },
              child: Text('test SENT'),
            ),

            if (germanSentence != null) Text(germanSentence!),

            if (englishSentence != null) Text(englishSentence!),

            if (germanSentence2 != null) Text(germanSentence2!),

            if (germanSentence3 != null) Text(germanSentence3!),

            if (englishSentence2 != null) Text(englishSentence2!),

            if (errorMessage != null) Text(errorMessage!),
          ],
        ),
      ),
    );
  }

  Future<void> translateWord() async {
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
      final result = await ApiService.getWord(word);
      final translated = await ApiService.translateShitty(sentence);
      scrapedData = ScrapedData(
        wordResponse: result,
        originalSentence: sentence,
        translatedSentence: translated,
      );
      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OutputScreen2(response: result, scrapedData: scrapedData!),
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
