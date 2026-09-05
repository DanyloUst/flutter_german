import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/models/api_exception.dart';
import 'package:flutter_german/screens/output_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: HomePage2())),
    );
  }
}

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController wordController = TextEditingController();
  TextEditingController sentenceController = TextEditingController();
  String? word;
  List<String>? translation;
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
            ElevatedButton(
              onPressed: () async {
                final definitions = await ApiService.getDefinition(
                  'bird',
                  'verb',
                );

                for (final definition in definitions) {
                  print(definition);
                }
              },
              child: Text('test DEF'),
            ),
            if (isLoading) const CircularProgressIndicator(),

            ElevatedButton(
              onPressed: () async {
                final sentence = sentenceController.text;
                if (sentence.isEmpty) {
                  return;
                }
                final word = wordController.text;
                if(word.isEmpty){
                  return;
                }
                final noWordSentence = sentence.replaceAll(word, '_____');
                final translated = await ApiService.translateSentence(sentence);
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
      translation = null;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getWord(word);
      setState(() {
        translation = result.translations;
        germanSentence = result.germanSentence;
        englishSentence = result.englishSentence;
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OutputScreen(response: result)),
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
