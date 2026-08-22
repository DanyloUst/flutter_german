import 'package:flutter/material.dart';
import 'package:flutter_german/api_service.dart';
import 'package:flutter_german/models/api_exception.dart';

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
  TextEditingController controller = TextEditingController();
  String? word;
  String? translation;
  String? errorMessage;
  String? germanSentence;
  String? englishSentence;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: controller),
            ElevatedButton(
              onPressed: isLoading ? null : translateWord,
              child: Text('test'),
            ),
            if (isLoading) const CircularProgressIndicator(),

            if (translation != null) Text(translation!),

            if (germanSentence != null) Text(germanSentence!),

            if (englishSentence != null) Text(englishSentence!),

            if (errorMessage != null) Text(errorMessage!),
          ],
        ),
      ),
    );
  }

  Future<void> translateWord() async {
    final word = controller.text.trim();

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
